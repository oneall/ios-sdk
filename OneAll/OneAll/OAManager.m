//
//  oneall.m
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAManager.h"
#import "OAWebLoginViewController.h"
#import "OASettings.h"
#import "OAServerApiConnectionGet.h"
#import "OALoginViewController.h"
#import "OAUserParser.h"
#import "OAServerApiMessagePost.h"
#import "OAFacebookLogin.h"
#import "OAServerApiUsersLoginNative.h"
#import "OALog.h"
#import "OATwitterLogin.h"
#import "OANetworkActivityIndicatorControl.h"
#import "OAProvider.h"
#import "NSString+ULREncode.h"
#import "OACommonTypes.h"

/* special provider type: Facebook. it requires special attention when logging in using native SDK */
static NSString *const kOaProviderFacebook = @"facebook";

/* special provider type: Twitter. it requires special attention when logging in using native SDK */
static NSString *const kOaProviderTwitter = @"twitter";

/* query parameter added to callback URL to identify current action */
static NSString *const kUrlQueryParamSdkAction = @"sdk_action";

@interface OAManager () <OAWebLoginDelegate, OALoginControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) OALoginCallbackFailure callbackFailure;
@property (strong, nonatomic) OALoginCallbackSuccess callbackSuccess;
@property (strong, nonatomic) OAServerApiConnectionGet *apiConnectionGet;
@property (strong, nonatomic) OAServerApiUsersLoginNative *apiConnectionNative;
@property (strong, nonatomic) OAServerApiMessagePost *apiMessagePost;

/* OneAll system uses nonce to identify sessions. after initial login, this services as a cookie to allow the server
 * to connect between the session opened and the user logged in. */
@property (strong, nonatomic) NSString *lastNonce;

/** last selected login provider */
@property (strong, nonatomic) OAProvider *selectedProvider;

@end

@implementation OAManager

#pragma mark - Lifecycle

/* initalization of singleton manager instance */
+ (instancetype)sharedInstance
{
    static OAManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
         _sharedInstance = [[OAManager alloc] init];
    });

    return _sharedInstance;
}

#pragma mark - Interface methods

- (BOOL)loginWithProvider:(NSString *)provider
                  success:(OALoginCallbackSuccess)success
                  failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    return [self internalLoginWithProvider:provider
                       andSocialLinkAction:OASocialLinkActionNone
                             andLinkedUser:nil
                                   success:success
                                   failure:failure];
}

- (BOOL)linkUser:(NSString *)userToken
        provider:(NSString *)provider
         success:(OALoginCallbackSuccess)success
         failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    return [self internalLoginWithProvider:provider
                       andSocialLinkAction:OASocialLinkActionLink
                             andLinkedUser:userToken
                                   success:success
                                   failure:failure];
}

- (BOOL)unlinkUser:(NSString *)userToken
          provider:(NSString *)provider
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    return [self internalLoginWithProvider:provider
                       andSocialLinkAction:OASocialLinkActionUnlink
                             andLinkedUser:userToken
                                   success:success
                                   failure:failure];
}

- (void)setupWithSubdomain:(NSString *)subdomain
{
    OALog(@"");
    [self setupWithSubdomain:subdomain facebookAppId:nil twitterConsumerKey:nil twitterSecret:nil];
}

- (void)setupWithSubdomain:(NSString *)subdomain
             facebookAppId:(NSString *)fbAppId
        twitterConsumerKey:(NSString *)twitterConsumerKey
            twitterSecret:(NSString *)twitterSecret
{
    OALog(@"Initializing OA auth with subdomain: %@ with FB appID: %@, Twitter keys: %@/%@",
        subdomain,
        fbAppId,
        twitterConsumerKey,
        twitterSecret);

    [[OASettings sharedInstance] setSubdomain:subdomain];

    /* initialize Facebook session */
    [[OAFacebookLogin sharedInstance] setFacebookAppId:fbAppId];
    [[OAFacebookLogin sharedInstance] openFbSession];

    /* initialize Twitter settings */
    [[OATwitterLogin sharedInstance] setConsumerKey:twitterConsumerKey andSecret:twitterSecret];

    /* load provder names from the server */
    [[OAProviderManager sharedInstance] refreshProviderNamesInBackgroundWithSubdomain:subdomain];
}

- (void)setNetworkActivityIndicatorControlledByOa:(BOOL)oaControl
{
    OALog(@"");
    if (oaControl)
    {
        [[OANetworkActivityIndicatorControl sharedInstance] takeControl];
    }
    else
    {
        [[OANetworkActivityIndicatorControl sharedInstance] releaseControl];
    }
}

- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    OALog(@"Handling URL open by the app: %@", url);
    return [[OAFacebookLogin sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication];
}

- (void)didBecomeActive
{
    OALog(@"");
    /* the only consumer of this message is Facebook login */
    [[OAFacebookLogin sharedInstance] didBecomeActive];
}

- (void)loginWithSuccess:(OALoginCallbackSuccess)success andFailure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    [OALoginViewController showWithDelegate:self];
}

- (void)linkUser:(NSString *)userToken success:(OALoginCallbackSuccess)success failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    OALoginViewController *lvc = [OALoginViewController showWithDelegate:self];
    lvc.userToken = userToken;
    lvc.action = OASocialLinkActionLink;
}

- (void)unlinkUser:(NSString *)userToken
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    OALoginViewController *lvc = [OALoginViewController showWithDelegate:self];
    lvc.userToken = userToken;
    lvc.action = OASocialLinkActionUnlink;
}

- (void)loginWithParentController:(UIViewController *)parentVc
                       andSuccess:(OALoginCallbackSuccess)success
                       andFailure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    [OALoginViewController showInContainer:parentVc withDelegate:self];
}

- (void)linkUser:(NSString *)userToken
parentViewController:(UIViewController *)parentVc
         success:(OALoginCallbackSuccess)success
         failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    OALoginViewController *lvc = [OALoginViewController showInContainer:parentVc withDelegate:self];
    lvc.userToken = userToken;
    lvc.action = OASocialLinkActionLink;
}

- (void)unlinkUser:(NSString *)userToken
parentViewController:(UIViewController *)parentVc
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure
{
    OALog(@"");
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    OALoginViewController *lvc = [OALoginViewController showInContainer:parentVc withDelegate:self];
    lvc.userToken = userToken;
    lvc.action = OASocialLinkActionUnlink;
}

- (BOOL)postMessageWithText:(NSString *)text
                 pictureUrl:(NSURL *)pictureUrl
                   videoUrl:(NSURL *)videoUrl
                    linkUrl:(NSURL *)linkUrl
                   linkName:(NSString *)linkName
                linkCaption:(NSString *)linkCaption
            linkDescription:(NSString *)linkDescription
             enableTracking:(BOOL)enableTracking
                  userToken:(NSString *)userToken
               publishToken:(NSString *)publishToken
                toProviders:(NSArray *)providers
                   callback:(OAMessagePostCallback)complete
{
    OALog(@"Posting share message");
    self.apiMessagePost = [[OAServerApiMessagePost alloc] init];

    if (!providers.count || !userToken.length)
    {
        OALog(@"Providers array cannot be empty and user toke is required");
        return false;
    }

    return [self.apiMessagePost postMessageWithText:text
                                         pictureUrl:pictureUrl
                                           videoUrl:videoUrl
                                            linkUrl:linkUrl
                                           linkName:linkName
                                        linkCaption:linkCaption
                                    linkDescription:linkDescription
                                     enableTracking:enableTracking
                                          userToken:userToken
                                       publishToken:publishToken
                                        toProviders:providers
                                           callback:^(BOOL failed, OAMessagePostResult *result, OAError *error)
                                           {
                                               /* relaying it here as we can one day process it here before passing the response to the caller */
                                               if (complete)
                                               {
                                                   complete(failed, result, error);
                                               }

                                           }];
}

- (NSArray *)providers
{
    OALog(@"");
    NSArray *objProviders = [[OAProviderManager sharedInstance] providers];
    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:[objProviders count]];
    [objProviders enumerateObjectsUsingBlock:^(OAProvider *obj, NSUInteger idx, BOOL *stop)
    {
        [rv addObject:obj.type];
    }];
    return rv;
}

#pragma mark - OAWebLoginDelegate

- (void)webLoginCancelled:(id)sender
{
    OALog(@"Web login cancelled");
    void (^cancelHandler)() = ^{
        if (self.callbackFailure)
        {
            self.callbackFailure([OAError errorWithMessage:@"Cancelled" andCode:OA_ERROR_CANCELLED]);
            self.callbackFailure = nil;
            self.callbackSuccess = nil;
        }
    };
    if (sender != nil)
    {
        [sender dismissViewControllerAnimated:YES completion:cancelHandler];
    }
    else
    {
        cancelHandler();
    }
}

- (void)webLoginFailed:(id)sender error:(NSError *)error
{
    [sender dismissViewControllerAnimated:true completion:^{
        if (self.callbackFailure)
        {
            self.callbackFailure(error);
            self.callbackFailure = nil;
            self.callbackSuccess = nil;
        }
    }];
}

/* in case of successful login connection/user information has to be retrieved, which will include information about the
 * user: name, avatar, etc. Once this information is retrieved, delegate is used to call back the using class.
 */
- (void)webLoginComplete:(id)sender withUrl:(NSURL *)url
{
    OALog(@"Web login complete with URL %@", url);
    
    /* in case of unlinking, we are done */
    if ([self parseSdkActionFromUrl:url] == OASocialLinkActionUnlink)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender dismissViewControllerAnimated:YES completion:nil];
        });
        if (self.callbackSuccess != nil)
        {
            self.callbackSuccess(nil, false);
            self.callbackSuccess = nil;
            self.callbackFailure = nil;
        }
        return;
    }

    /* any other action except for unlink */
    NSString *token = [self parseConnectionTokenFromUrl:url];

    self.apiConnectionGet = [[OAServerApiConnectionGet alloc] init];

    void (^apiCompleteBlock)(NSDictionary *ud, NSError *err) = ^(NSDictionary *ud, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender dismissViewControllerAnimated:YES completion:nil];
        });
        
        if (ud != nil && err == nil) {
            OAUser *user = [OAUserParser parseUser:ud];
            if (self.callbackSuccess)
            {
                self.callbackSuccess(user, false);
                self.callbackSuccess = nil;
                self.callbackFailure = nil;
            }
        }
        else {
            if (self.callbackFailure) {
                self.callbackFailure(err);
                self.callbackFailure = nil;
                self.callbackSuccess = nil;
            }
        }

    };

    BOOL res =
    [self.apiConnectionGet getInfoWithConnectionToken:token andNonce:self.lastNonce andComplete:apiCompleteBlock];

    if (!res && self.callbackFailure)
    {
        self.callbackFailure([OAError errorWithMessage:@"Invalid request" andCode:OA_ERROR_INVALID_REQUEST]);
        self.callbackFailure = nil;
        self.callbackSuccess = nil;
    }
}

#pragma mark - Utilities

/* start login with specified provider */
- (void)webLoginWithSocialLinkAction:(OASocialLinkAction)action userToken:(NSString *)linkedUserToken
{
    if (self.selectedProvider.userInputRequired)
    {
        NSString *message =
                [NSString stringWithFormat:NSLocalizedString(@"Please, enter your %@ %@ to login with", @""),
                                           self.selectedProvider.name,
                                           self.selectedProvider.userInputTitle];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:self.selectedProvider.name
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
            textField.placeholder = self.selectedProvider.userInputTitle;
        }];
        
        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"OK", @"")
                                                  style:UIAlertActionStyleDefault
                                                handler:^(UIAlertAction *alertAction)
                          {
                              NSString *userText = [alert.textFields[0] text];
                              if ([userText length] > 0)
                              {
                                  [self webLoginWithLoginData:userText
                                             socialLinkAction:action
                                                   linkedUser:linkedUserToken];
                              }
                              else
                              {
                                  [self webLoginCancelled:nil];
                              }
                          }]];

        [alert addAction:[UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", @"")
                                                  style:UIAlertActionStyleCancel
                                                handler:^(UIAlertAction *action) {
                                                    [self webLoginCancelled:nil];
                                                }]];

        [[[[UIApplication sharedApplication] keyWindow] rootViewController] presentViewController:alert
                                                                                         animated:NO
                                                                                       completion:nil];
    }
    else
    {
        [self webLoginWithLoginData:nil socialLinkAction:action linkedUser:linkedUserToken];
    }
}

/* start login with specified provider */
- (void)webLoginWithLoginData:(NSString *)loginData
             socialLinkAction:(OASocialLinkAction)action
                   linkedUser:(NSString *)linkedUserToken
{
    NSURL *url = [self apiUrlForProvider:self.selectedProvider.type
                               withNonce:self.lastNonce
                               loginData:loginData
                        socialLinkAction:action
                               userToken:linkedUserToken];

    OALog(@"Web login with provider %@ and url: %@", self.selectedProvider.type, url);

    UIViewController *vc = [OAWebLoginViewController webLoginWithDelegate:self andUrl:url];

    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootVC presentViewController:vc animated:YES completion:nil];
}

/* callback of successful facebook login: continues to information retrieval from OneAll server before completing login
 * operation */
- (void)facebookLoginSucceeded:(NSString *)sessionToken
              socialLinkAction:(OASocialLinkAction)action
                    linkedUser:(NSString *)linkedUserToken
{
    OALog(@"Facebook login succeeded with token %@", sessionToken);
    
    self.apiConnectionNative = [[OAServerApiUsersLoginNative alloc] init];

    __weak OAManager *_wSelf = self;
    OAServerApiUsersLoginNativeCallback apiCompleteBlock = ^(NSDictionary *ud, BOOL newUser, NSError *err) {
        OAUser *user = [OAUserParser parseUser:ud];
        if (_wSelf.callbackSuccess)
        {
            _wSelf.callbackSuccess(user, newUser);
            _wSelf.callbackSuccess = nil;
            _wSelf.callbackFailure = nil;
        }
    };

    BOOL res;

    if (action == OASocialLinkActionUnlink) {
        res = [self.apiConnectionNative unlinkWithFacebookToken:sessionToken
                                                      userToken:linkedUserToken
                                                       complete:apiCompleteBlock];
    }
    else {
        res = [self.apiConnectionNative getInfoWithFacebookToken:sessionToken
                                                       userToken:linkedUserToken
                                                        complete:apiCompleteBlock];
    }

    if (!res && self.callbackFailure)
    {
        self.callbackFailure([OAError errorWithMessage:@"Invalid request" andCode:OA_ERROR_INVALID_REQUEST]);
        self.callbackFailure = nil;
        self.callbackSuccess = nil;
    }
}

/** in case of failure to login with native Facebook login, fall back to original OneAll based web window */
- (void)facebookLoginFailed:(NSError *)error
                userMessage:(NSString *)userMessage
           socialLinkAction:(OASocialLinkAction)action
                 linkedUser:(NSString *)linkedUserToken
{
    OALog(@"Failed to login with native Facebook authentication");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self webLoginWithSocialLinkAction:action userToken:linkedUserToken];
    });
}

- (void)twitterLoginDoneWithToken:(NSString *)token
                           secret:(NSString *)secret
                 socialLinkAction:(OASocialLinkAction)action
                       linkedUser:(NSString *)linkedUserToken
{
    OALog(@"Twitter login done with token: %@ and secret: %@", token, secret);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!token)
        {
            [self webLoginWithSocialLinkAction:action userToken:linkedUserToken];
            return;
        }

        self.apiConnectionNative = [[OAServerApiUsersLoginNative alloc] init];

        __weak OAManager *_wSelf = self;
        OAServerApiUsersLoginNativeCallback apiCompleteBlock = ^(NSDictionary *ud, BOOL newUser, NSError *err) {
            OAUser *user = [OAUserParser parseUser:ud];
            if (_wSelf.callbackSuccess)
            {
                _wSelf.callbackSuccess(user, newUser);
                _wSelf.callbackSuccess = nil;
                _wSelf.callbackFailure = nil;
            }
        };

        BOOL res;
        
        if (action == OASocialLinkActionUnlink) {
            res = [self.apiConnectionNative unlinkWithTwitterToken:token
                                                            secret:secret
                                                         userToken:linkedUserToken
                                                          complete:apiCompleteBlock];
        }
        else {
            res = [self.apiConnectionNative getInfoWithTwitterToken:token
                                                             secret:secret
                                                          userToken:linkedUserToken
                                                           complete:apiCompleteBlock];
        }

        if (!res && self.callbackFailure)
        {
            self.callbackFailure([OAError errorWithMessage:@"Invalid request" andCode:OA_ERROR_INVALID_REQUEST]);
            self.callbackFailure = nil;
            self.callbackSuccess = nil;
        }
    });
}

- (NSString *)parseQueryParam:(NSString *)name fromUrl:(NSURL *)url
{
    NSError *error;
    NSString *rexString = [NSString stringWithFormat:@".*%@=([^&]+).*", name];
    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:rexString
                                                                         options:0
                                                                           error:&error];
    
    NSTextCheckingResult *match = [rex firstMatchInString:url.query options:0 range:NSMakeRange(0, url.query.length)];
    if (!match)
    {
        return nil;
    }
    
    NSRange range = [match rangeAtIndex:1];
    
    return [url.query substringWithRange:range];
}

- (NSString *)parseConnectionTokenFromUrl:(NSURL *)url
{
    return [self parseQueryParam:@"connection_token" fromUrl:url];
}

- (OASocialLinkAction)parseSdkActionFromUrl:(NSURL *)url
{
    NSString *val = [self parseQueryParam:kUrlQueryParamSdkAction fromUrl:url];
    if ([val length] > 0)
    {
        NSNumberFormatter *nf = [[NSNumberFormatter alloc] init];
        nf.numberStyle = NSNumberFormatterDecimalStyle;
        return (OASocialLinkAction) [[nf numberFromString:val] integerValue];
    }
    return OASocialLinkActionNone;
}

/* create authentication URL for specified provider type */
- (NSURL *)apiUrlForProvider:(NSString *)providerType
                   withNonce:(NSString *)nonce
                   loginData:(NSString *)loginData
            socialLinkAction:(OASocialLinkAction)action
                   userToken:(NSString *)userToken
{
    NSString *callbackUri =
    [NSString stringWithFormat:@"oneall://%@%%3f%@=%d", providerType, kUrlQueryParamSdkAction, (int)action];
    
    NSString *url = [NSString stringWithFormat:
                     @"https://%@.api.oneall.com/socialize/connect/mobile/%@/?nonce=%@&callback_uri=%@",
                     [OASettings sharedInstance].subdomain,
                     providerType,
                     nonce,
                     callbackUri];
    if (userToken != nil && action != OASocialLinkActionNone)
    {
        url = [url stringByAppendingFormat:@"&service=social_link&action=%@&user_token=%@",
               (action == OASocialLinkActionLink) ? @"link_identity" : @"unlink_identity",
               [userToken urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    if (loginData != nil)
    {
        url = [url stringByAppendingFormat:@"&login_data=%@", [loginData urlEncodeUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return [NSURL URLWithString:url];
}

- (BOOL)internalLoginWithProvider:(NSString *)provider
              andSocialLinkAction:(OASocialLinkAction)action
                    andLinkedUser:(NSString *)userToken
                          success:(OALoginCallbackSuccess)success
                          failure:(OALoginCallbackFailure)failure
{
    self.selectedProvider = [[OAProviderManager sharedInstance] providerWithType:provider];
    
    if (self.selectedProvider == nil)
    {
        OALog(@"Invalid provider type: %@", provider);
        return false;
    }
    
    if (self.selectedProvider.isConfigurationRequired && !self.selectedProvider.isConfigured)
    {
        OALog(@"Provider %@ not configured", provider);
        return false;
    }
    
    OALog(@"Login with provider: %@", self.selectedProvider.type);
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    
    self.lastNonce = [[NSUUID UUID] UUIDString];
    
    BOOL nativeLoginSuccessful = false;
    
    /* for Twitter/Facebook, try to use native SDK's and fall back to web login in case of failure */
    if ([provider isEqualToString:kOaProviderFacebook] && [[OAFacebookLogin sharedInstance] enabled])
    {
        void (^fbSuccessHandler)(NSString *) = ^(NSString *sessionToken) {
            [self facebookLoginSucceeded:sessionToken
                        socialLinkAction:action
                              linkedUser:userToken];
        };
        
        void (^fbFailureHandler)(NSError *,NSString *) = ^(NSError *error, NSString *userMessage)
        {
            [self facebookLoginFailed:error userMessage:userMessage
                     socialLinkAction:action
                           linkedUser:userToken];
        };
        
        nativeLoginSuccessful = [[OAFacebookLogin sharedInstance] loginSuccess:fbSuccessHandler
                                                                       failure:fbFailureHandler];
    }
    else if ([provider isEqualToString:kOaProviderTwitter] && [[OATwitterLogin sharedInstance] canBeUsed])
    {
        nativeLoginSuccessful = [[OATwitterLogin sharedInstance] login:^(NSString *token, NSString *secret)
                                 {
                                     [self twitterLoginDoneWithToken:token
                                                              secret:secret
                                                    socialLinkAction:action
                                                          linkedUser:userToken];
                                 }];
    }
    
    if (!nativeLoginSuccessful)
    {
        [self webLoginWithSocialLinkAction:action userToken:userToken];
    }
    
    return true;
}


#pragma mark - OALoginControllerDelegate

/* implementation of OALoginControllerDelegate: called when the user selected one of providers in own view controller
 * with providers selector */
- (void)oaLoginController:(OALoginViewController *)sender selectedMethod:(OAProvider *)provider
{
    OALog(@"Logging in with provider: %@", provider.name);
    
    [sender dismissViewControllerAnimated:YES completion:^{
        switch (sender.action)
        {
            case OASocialLinkActionLink:
                [self linkUser:sender.userToken
                      provider:provider.type
                       success:self.callbackSuccess
                       failure:self.callbackFailure];
                break;
            case OASocialLinkActionUnlink:
                [self unlinkUser:sender.userToken
                        provider:provider.type
                         success:self.callbackSuccess
                         failure:self.callbackFailure];
                break;
            default:
                [self loginWithProvider:provider.type
                                success:self.callbackSuccess
                                failure:self.callbackFailure];
                break;
        }
    }];
}

/* own view controller with provider selection closed without choosing one of login providers */
- (void)oaLoginControllerCancelled:(id)sender
{
    OALog(@"");
    [sender dismissViewControllerAnimated:YES completion:nil];
    if (self.callbackFailure)
    {
        self.callbackFailure([OAError errorWithMessage:@"Cancelled" andCode:OA_ERROR_CANCELLED]);
    }
}

@end
