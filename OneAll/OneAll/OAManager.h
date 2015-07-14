//
//  oneall.h
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OAProviderManager.h"
#import "OAUser.h"
#import "OAIdentity.h"
#import "OAMessagePostResult.h"

typedef void (^OALoginCallbackSuccess)(OAUser *user, BOOL newUser);
typedef void (^OALoginCallbackFailure)(NSError *error);

/**
 * OAManager is the central point of access to OneAll library. In order to activate the library, the following steps
 * are required:
 * - in your `[UIApplication application:didFinishLaunchingWithOptions:]` initialize the manager:
 * @code
 * - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 * {
 *     [[OAManager sharedInstance] setupWithSubdomain:@"testdemmo"
 *                                      facebookAppId:@"20531316728"
 *                                 twitterConsumerKey:@"DTH9zxcsqxtsQV2pJF0ao7KGeN0"
 *                                      twitterSecret:@"BYkuaZsDdaDgTzLuNJE9ScesD4DSSxOKg3P5xcEcotn5imWwWO"];
 *     // other application initializations here
 *     return YES;
 * }
 * @endcode
 *
 * Pass the `applicationDidBecomeActive' mess to manager too:
 * @code
 * - (void)applicationDidBecomeActive:(UIApplication *)application
 * {
 *     [[OAManager sharedInstance] didBecomeActive];
 * }
 * @endcode
 *
 * If you use native Facebook login, override URL handling in your `UIApplication` too:
 * @code
 * - (BOOL)application:(UIApplication *)application
 *             openURL:(NSURL *)url
 *   sourceApplication:(NSString *)sourceApplication
 *          annotation:(id)annotation
 * {
 *     return [[OAManager sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication];
 * }
 * @endcode
 *
 * In addition to passing `application:openURL:sourceApplication:annotation` message to the manager, in order for native
 * Facebook authentication to work you have to add the Facebook SDK to the project as described by [Facebook
 * documentation](https://developers.facebook.com/docs/ios/). Don't forget to take care of URL types.
 */
@interface OAManager : NSObject

+ (instancetype)sharedInstance;

/**
* setup the application for subdomain, should generally be called from application:didFinishLaunchingWithOptions:
*
* @param subdomain subdomain of OneAll application without the .oneall.com part. For example for subdomain
*    http://foo.oneall.com pass only the "foo" part.
*/
- (void)setupWithSubdomain:(NSString *)subdomain;

/**
* setup the application for subdomain, should generally be called from application:didFinishLaunchingWithOptions:
*
* @param subdomain subdomain of OneAll application without the .oneall.com part. For example for subdomain
*    http://foo.oneall.com pass only the "foo" part.
*
* @param fbAppId AppID of the Facebook application, required only if native Facebook authentication is used
*
* @param twitterConsumerKey consumer key of Twitter application. If omitted, native Twitter authentication will be
*  disabled
*
* @param twitterSecret Twitter consumer key of Twitter application. If omitted, native Twitter authentication will be
*  disabled
*/
- (void)setupWithSubdomain:(NSString *)subdomain
             facebookAppId:(NSString *)fbAppId
        twitterConsumerKey:(NSString *)twitterConsumerKey
             twitterSecret:(NSString *)twitterSecret;

/** sets the manager flag allowing the OneAll library to control activity indicator */
- (void)setNetworkActivityIndicatorControlledByOa:(BOOL)oaControl;

/** should be called from - application:openURL:sourceApplication:annotation: in order for native Facebook
 * authentication to work
 *
 * @param url URL with which the application was opened
 *
 * @param sourceApplication original parameter passed to application:openURL:sourceApplication:annotation:
 */
- (BOOL)handleOpenUrl:(NSURL *)url sourceApplication:(NSString *)sourceApplication;

/** should be called when application did become active and, generally, called from applicationDidBecomeActive: of your
 * AppDelegate class */
- (void)didBecomeActive;

/** login using specified provider
 *
 * @param provider provider type to use
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 *
 * @return `true` if the login has been started successfully, `false` if the provider does not exist or if the provider
 *  is not configured and should be setup before use.
 */
- (BOOL)loginWithProvider:(NSString *)provider
                  success:(OALoginCallbackSuccess)success
                  failure:(OALoginCallbackFailure)failure;


/** use social link feature to link existing user to speicified provider
 *
 * @param provider provider type to link the user to
 *
 * @param userToken token of the user to link to new provider; the value is obtained from @c OAUser.userToken after 
 *  succcessful login
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 *
 * @return `true` if the link has been started successfully, `false` if the provider does not exist or if the provider
 *  is not configured and should be setup before use.
 */
- (BOOL)linkUser:(NSString *)userToken
        provider:(NSString *)provider
         success:(OALoginCallbackSuccess)success
         failure:(OALoginCallbackFailure)failure;

/** use social link feature to unlink existing user from specified provider
 *
 * @param provider provider type to link the user to
 *
 * @param userToken token of the user to unlink from provider; the value is obtained from @c OAUser.userToken after
 *  succcessful login
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 *
 * @return `true` if the unlink has been started successfully, `false` if the provider does not exist or if the provider
 *  is not configured and should be setup before use.
 */
- (BOOL)unlinkUser:(NSString *)userToken
          provider:(NSString *)provider
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure;

/** login using own provider selector @c OALoginViewController
 *
 * The method will show a view with the selection of all possible providers. If the user has selected one of the
 * providers, login attempt will be performed and the result will be passed to the caller usong one of the callback
 * methods. The view shown will be added as a child view of a root application window.
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)loginWithSuccess:(OALoginCallbackSuccess)success andFailure:(OALoginCallbackFailure)failure;

/** use social link to login the user into new social provider while linking identities
 *
 * the method operates like regular @c loginWithSuccess:andFailure but links the user to new social provider.
 *
 * @param userToken token of the user to unlink from provider; the value is obtained from @c OAUser.userToken after
 *  succcessful login
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)linkUser:(NSString *)userToken success:(OALoginCallbackSuccess)success failure:(OALoginCallbackFailure)failure;

/** logout the user and unlink from social provider that will be selected for unlink.
 *
 * @param userToken token of the user to unlink from selected social provider
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)unlinkUser:(NSString *)userToken
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure;

/** login using own provider selector (OALoginViewController).
 *
 * The method will show a view with the selection of all possible providers. If the user has selected one of the
 * providers, login attempt will be performed and the result will be passed to the caller usong one of the callback
 * methods.
 * The view shown will be presented with presentViewController on the provided parent view controller
 *
 * @param parentVc parent view controller used for GUI operations
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)loginWithParentController:(UIViewController *)parentVc
                       andSuccess:(OALoginCallbackSuccess)success
                       andFailure:(OALoginCallbackFailure)failure;

/** use social link to login the user into new social provider while linking identities
 *
 * the method operates like regular @c loginWithSuccess:andFailure but links the user to new social provider.
 *
 * @param userToken token of the user to unlink from provider; the value is obtained from @c OAUser.userToken after
 *  succcessful login
 *
 * @param parentVc parent view controller used for GUI operations
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)linkUser:(NSString *)userToken
parentViewController:(UIViewController *)parentVc
         success:(OALoginCallbackSuccess)success
         failure:(OALoginCallbackFailure)failure;

/** logout the user and unlink from social provider that will be selected for unlink.
 *
 * @param userToken token of the user to unlink from selected social provider
 *
 * @param parentVc parent view controller used for GUI operations
 *
 * @param success success callback method
 *
 * @param failure failure callback method
 */
- (void)unlinkUser:(NSString *)userToken
parentViewController:(UIViewController *)parentVc
           success:(OALoginCallbackSuccess)success
           failure:(OALoginCallbackFailure)failure;


/** post to user's wall on all the specified providers.
 *
 * Parameters marked as [optional] can be set to nil
 *
 * @param text text of the posted message
 *
 * @param pictureUrl URL of the picture attached to the message [optional]
 *
 * @param videoUrl URL of the video attached to the message [optional]
 *
 * @param linkUrl URL attached to the message [optional]
 *
 * @param linkCaption caption of the link [optional]
 *
 * @param linkDescription detail description of the posted link [optional]
 *
 * @param enableTracking enabling tracking of the link [optional]
 *
 * @param userToken current user token OAUser.userToken
 *
 * @param publishToken current user publish token OAUser.publishToken.key
 *
 * @param providers array of boxed OAProviderType objects. `@[@(OA_PROVIDER_GITHUB), @(OA_PROVIDER_GOOGLE)]`.
 * This parameter cannot be empty and has to have at least one provider
 *
 * @param complete callback used to inform the user caller about asynchronous operation status
 *
 * @return `false` for invalid request, in which case callback will not be called, `true` if the request has been
 * created successfully and sent to server.
 */
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
                   callback:(OAMessagePostCallback)complete;

/**
 *  get list of providers supported by the SDK
 *
 * @return array of provider types supported
 */
- (NSArray *)providers;

@end
