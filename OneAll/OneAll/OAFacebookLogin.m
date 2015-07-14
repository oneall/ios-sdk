//
//  OAFacebookLogin.m
//  oneall
//
//  Created by Uri Kogan on 8/8/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAFacebookLogin.h"
#import "OALog.h"
#import "FacebookSDK.h"

@interface OAFacebookLogin ()

@property (strong, nonatomic) OAFacebookLoginSuccessCallback successCallback;
@property (strong, nonatomic) OAFacebookLoginFailureCallback failureCallback;

@end

@implementation OAFacebookLogin

#pragma mark Lifecycle

+ (instancetype)sharedInstance
{
    static OAFacebookLogin *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OAFacebookLogin alloc] init];
    });

    return _sharedInstance;
}

#pragma mark - Interface methods

- (BOOL)enabled
{
    return ([NSClassFromString(@"FBSettings") class] != nil) && (self.facebookAppId.length > 0);
}

/** comes straight from Facebook example
 * https://developers.facebook.com/docs/facebook-login/ios/v2.1
 */
- (void)openFbSession
{
    OALog(@"Initializing Facebook login");
    if (self.facebookAppId == nil)
    {
        OALog(@"Facebook application is not setup, skipping Facebook SDK initialization");
        return;
    }
    [[NSClassFromString(@"FBSettings") class] setDefaultAppID:self.facebookAppId];
    Class fbSession = [NSClassFromString(@"FBSession") class];
    if (fbSession && [[fbSession activeSession] state] == FBSessionStateCreatedTokenLoaded)
    {
        OALog(@"Renewing Facebook session token");
        [fbSession openActiveSessionWithReadPermissions:@[@"public_profile", @"publish_actions"]
                                           allowLoginUI:NO
                                      completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                          [self sessionStateChanged:session state:state error:error];
                                      }];
    }

}

/** login into Facebook using application settings */
- (BOOL)loginSuccess:(OAFacebookLoginSuccessCallback)successCallback
             failure:(OAFacebookLoginFailureCallback)failureCallback
{
    self.successCallback = successCallback;
    self.failureCallback = failureCallback;

    Class fbSession = [NSClassFromString(@"FBSession") class];

    if (!fbSession)
    {
        return false;
    }

    [fbSession openActiveSessionWithReadPermissions:@[@"public_profile"]
                                       allowLoginUI:YES
                                  completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                      [self sessionStateChanged:session state:state error:error];
                                  }];
    return true;
}

- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication
{
    /* accessing FBAppCall class by name allows to work without linked Facebook SDK */
    Class fbAppCall = NSClassFromString(@"FBAppCall");
    return (fbAppCall != nil) ? [fbAppCall handleOpenURL:url sourceApplication:sourceApplication] : YES;
}

- (void)didBecomeActive
{
    /* accessing FBAppCall class by name allows to work without linked Facebook SDK */
    Class fbAppCall = NSClassFromString(@"FBAppCall");
    if (fbAppCall && self.facebookAppId != nil)
    {
        [fbAppCall handleDidBecomeActive];
    }
}

#pragma mark - Facebook callback

/** handler of Facebook states. Taken straight from Facebook tutorial:
 *  https://developers.facebook.com/docs/facebook-login/ios/v2.1 */
- (void)sessionStateChanged:(FBSession *)session state:(FBSessionState)state error:(NSError *)error
{
    OAFacebookLoginSuccessCallback successCallback = self.successCallback;
    OAFacebookLoginFailureCallback failureCallback = self.failureCallback;
    NSString *userErrorMessage;

    OALog(@"Facebook session state change. Session %@, state=%d, error=%@", session, (int)state, error);

    // If the session was opened successfully
    if (!error && state == FBSessionStateOpen)
    {
        if (successCallback)
        {
            successCallback([[[[NSClassFromString(@"FBSession") class] activeSession] accessTokenData] accessToken]);
            self.successCallback = nil;
            self.failureCallback = nil;
        }

        return;
    }

    /* accessing FBErrorUtility class by name allows to work without linked Facebook SDK */
    Class fbErrorUtility = NSClassFromString(@"FBErrorUtility");
    if (error && [fbErrorUtility shouldNotifyUserForError:error])
    {
        userErrorMessage = [fbErrorUtility userMessageForError:error];
    }

    if (error || state == FBSessionStateClosedLoginFailed)
    {
        if (failureCallback)
        {
            failureCallback(error, userErrorMessage);
            self.successCallback = nil;
            self.failureCallback = nil;
        }
        [[[NSClassFromString(@"FBSession") class] activeSession] closeAndClearTokenInformation];
    }
}

@end
