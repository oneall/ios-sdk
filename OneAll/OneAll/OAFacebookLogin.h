//
//  OAFacebookLogin.h
//  oneall
//
//  Created by Uri Kogan on 8/8/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/** callback for successful login using native Facebook authentication
 *
 * @param sessionToken session token of the user received during Facebook authentication */
typedef void (^OAFacebookLoginSuccessCallback)(NSString *sessionToken);

/** callback for failed login using native Facebook authentication
 *
 * @param error error that occurred during login
 *
 * @param userMessage message to be shown to the user as returned by Facebook*/
typedef void (^OAFacebookLoginFailureCallback)(NSError *error, NSString *userMessage);

/** implementation of native Facebook login using installed Facebook application and Facebook SDK
 * the class is meant to be used as a singleton */
@interface OAFacebookLogin : NSObject

/** Facebook AppID has to be setup before using this class */
@property (strong, nonatomic) NSString *facebookAppId;

/** shared instance of the object to be used */
+ (instancetype)sharedInstance;

/** login into Facebook with success and failure callbacks. Successful login will return Facebook session token that
 * can be used to continue authentication with OneAll
 *
 * @param successCallback callback function that will be called upon successful Facebook login
 *
 * @param failureCallback callback function that will be called on failed Facebook attempt */
- (BOOL)loginSuccess:(OAFacebookLoginSuccessCallback)successCallback
             failure:(OAFacebookLoginFailureCallback)failureCallback;

/** method should be called on application start */
- (void)openFbSession;

/** method that should be called from during UIApplication launch with URL:
 * [UIApplication application:openURL:sourceApplication:annotation:].
 *
 * Actually, it is called by OAManager while it being set up
 */
- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/** handler of application becoming active message sent to UIApplication */
- (void)didBecomeActive;

/**
 * is thie native Facebook authentication enabled?
 * @return `true` if the native Facebook authentication is setup correctly, `false` otherwise
  */
- (BOOL)enabled;

@end
