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

@interface OAManager () <OAWebLoginDelegate, OALoginControllerDelegate>

@property (strong, nonatomic) OALoginCallbackFailure callbackFailure;
@property (strong, nonatomic) OALoginCallbackSuccess callbackSuccess;
@property (strong, nonatomic) OAServerApiConnectionGet *apiConnectionGet;
@property (strong, nonatomic) OAServerApiUsersLoginNative *apiConnectionNative;
@property (strong, nonatomic) OAServerApiMessagePost *apiMessagePost;

/* OneAll system uses nonce to identify sessions. after initial login, this services as a cookie to allow the server
 * to connect between the session opened and the user logged in. */
@property (strong, nonatomic) NSString *lastNonce;

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

- (void)loginWithProvider:(OAProviderType)provider
                  success:(OALoginCallbackSuccess)success
                  failure:(OALoginCallbackFailure)failure
{
    OALog(@"Login with provider: %@", [[OAProvider sharedInstance] providerName:provider]);
    self.callbackFailure = failure;
    self.callbackSuccess = success;

    self.lastNonce = [[NSUUID UUID] UUIDString];
    
    BOOL nativeLoginSuccessful = false;

    /* for Twitter/Facebook, try to use native SDK's and fall back to web login in case of failure */
    if (provider == OA_PROVIDER_FACEBOOK && [[OAFacebookLogin sharedInstance] enabled])
    {
        nativeLoginSuccessful = [[OAFacebookLogin sharedInstance] loginSuccess:^(NSString *sessionToken)
                              {
                                  [self facebookLoginSucceeded:sessionToken];
                              }
                                                                    failure:^(NSError *error, NSString *userMessage)
                              {
                                  [self facebookLoginFailed:error userMessage:userMessage];
                              }];
    }
    else if (provider == OA_PROVIDER_TWITTER && [[OATwitterLogin sharedInstance] canBeUsed])
    {
        nativeLoginSuccessful = [[OATwitterLogin sharedInstance] login:^(NSString *token, NSString *secret)
        {
            [self twitterLoginDoneWithToken:token secret:secret];
        }];
    }

    if (!nativeLoginSuccessful)
    {
        [self webLoginWithProvider:provider];
    }
}

- (void)setupWithSubdomain:(NSString *)subdomain
{
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
}

- (void)setNetworkActivityIndicatorControlledByOa:(BOOL)oaControl
{
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
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    [OALoginViewController showWithDelegate:self];
}

- (void)loginWithParentController:(UIViewController *)parentVc
                       andSuccess:(OALoginCallbackSuccess)success
                       andFailure:(OALoginCallbackFailure)failure
{
    self.callbackFailure = failure;
    self.callbackSuccess = success;
    [OALoginViewController showInContainer:parentVc withDelegate:self];
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

#pragma mark - OAWebLoginDelegate

- (void)webLoginCancelled:(id)sender
{
    OALog(@"Web login cancelled");
    [sender dismissViewControllerAnimated:YES completion:nil];
    if (self.callbackFailure)
    {
        self.callbackFailure([OAError errorWithMessage:@"Cancelled" andCode:OA_ERROR_CANCELLED]);
        self.callbackFailure = nil;
        self.callbackSuccess = nil;
    }
}

/* in case of successful login connection/user information has to be retrieved, which will include information about the
 * user: name, avatar, etc. Once this information is retrieved, delegate is used to call back the using class.
 */
- (void)webLoginComplete:(id)sender withUrl:(NSURL *)url
{
    OALog(@"Web login complete with URL %@", url);

    NSString *token = [self parseConnectionTokenFromUrl:url];

    self.apiConnectionGet = [[OAServerApiConnectionGet alloc] init];

    void (^apiCompleteBlock)(NSDictionary *ud, NSError *err) = ^(NSDictionary *ud, NSError *err) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [sender dismissViewControllerAnimated:YES completion:nil];
        });

        OAUser *user = [OAUserParser parseUser:ud];
        if (self.callbackSuccess)
        {
            self.callbackSuccess(user, false);
            self.callbackSuccess = nil;
            self.callbackFailure = nil;
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
- (void)webLoginWithProvider:(OAProviderType)provider
{
    NSURL *url = [self apiUrlForProvider:provider withNonce:self.lastNonce];

    OALog(@"Web login with provider %@ and url: %@", [[OAProvider sharedInstance] providerName:provider], url);

    UIViewController *vc = [OAWebLoginViewController webLoginWithDelegate:self andUrl:url];

    UIViewController *rootVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootVC presentViewController:vc animated:YES completion:nil];
}

/* callback of successful facebook login: continues to information retrieval from OneAll server before completing login
 * operation */
- (void)facebookLoginSucceeded:(NSString *)sessionToken
{
    OALog(@"Facebook login succeeded with token %@", sessionToken);

    self.apiConnectionNative = [[OAServerApiUsersLoginNative alloc] init];

    OAServerApiUsersLoginNativeCallback apiCompleteBlock = ^(NSDictionary *ud, BOOL newUser, NSError *err) {
        OAUser *user = [OAUserParser parseUser:ud];
        if (self.callbackSuccess)
        {
            self.callbackSuccess(user, newUser);
            self.callbackSuccess = nil;
            self.callbackFailure = nil;
        }
    };

    BOOL res = [self.apiConnectionNative getInfoWithFacebookToken:sessionToken andComplete:apiCompleteBlock];

    if (!res && self.callbackFailure)
    {
        self.callbackFailure([OAError errorWithMessage:@"Invalid request" andCode:OA_ERROR_INVALID_REQUEST]);
        self.callbackFailure = nil;
        self.callbackSuccess = nil;
    }
}

/** in case of failure to login with native Facebook login, fall back to original OneAll based web window */
- (void)facebookLoginFailed:(NSError *)error userMessage:(NSString *)userMessage
{
    OALog(@"Failed to login with native Facebook authentication");
    dispatch_async(dispatch_get_main_queue(), ^{
        [self webLoginWithProvider:OA_PROVIDER_FACEBOOK];
    });
}

- (void)twitterLoginDoneWithToken:(NSString *)token secret:(NSString *)secret
{
    OALog(@"Twitter login done with token: %@ and secret: %@", token, secret);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (!token)
        {
            [self webLoginWithProvider:OA_PROVIDER_TWITTER];
            return;
        }

        self.apiConnectionNative = [[OAServerApiUsersLoginNative alloc] init];

        OAServerApiUsersLoginNativeCallback apiCompleteBlock = ^(NSDictionary *ud, BOOL newUser, NSError *err) {
            OAUser *user = [OAUserParser parseUser:ud];
            if (self.callbackSuccess)
            {
                self.callbackSuccess(user, newUser);
                self.callbackSuccess = nil;
                self.callbackFailure = nil;
            }
        };

        BOOL res = [self.apiConnectionNative getInfoWithTwitterToken:token secret:secret complete:apiCompleteBlock];

        if (!res && self.callbackFailure)
        {
            self.callbackFailure([OAError errorWithMessage:@"Invalid request" andCode:OA_ERROR_INVALID_REQUEST]);
            self.callbackFailure = nil;
            self.callbackSuccess = nil;
        }
    });
}

- (NSString *)parseConnectionTokenFromUrl:(NSURL *)url
{
    NSError *error;
    NSRegularExpression *rex = [NSRegularExpression regularExpressionWithPattern:@".*connection_token=([^&]+).*"
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

/* create authentication URL for specified provider type */
- (NSURL *)apiUrlForProvider:(OAProviderType)provider withNonce:(NSString *)nonce
{
    NSString *url = [NSString stringWithFormat:
                     @"https://%@.api.oneall.com/socialize/connect/mobile/%@/?nonce=%@&callback_uri=oneall://%@",
                     [OASettings sharedInstance].subdomain,
                     [[OAProvider sharedInstance] providerName:provider],
                     nonce,
                     [[OAProvider sharedInstance] providerName:provider]];

    return [NSURL URLWithString:url];
}

#pragma mark - OALoginControllerDelegate

/* implementation of OALoginControllerDelegate: called when the user selected one of providers in own view controller
 * with providers selector */
- (void)oaLoginController:(id)sender selectedMethod:(OAProviderType)provider
{
    OALog(@"Logging in with provider: %@", [[OAProvider sharedInstance] providerName:provider]);
    [sender dismissViewControllerAnimated:YES completion:^{
        [self loginWithProvider:provider success:self.callbackSuccess failure:self.callbackFailure];
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
