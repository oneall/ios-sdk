//
// Created by Uri Kogan on 10/7/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAServerApiBase.h"

/**
 * native user information callback method. Sends user dictionary and optional error to the caller
 *
 * @param userDict user dictionary as received from the server
 *
 * @param newUser `true` if the user has been created on OneAll server by the call, `false` if this is repeated login
 *
 * @param error if there are errors in the process, this is parameter will be non nil. It is possible there will be
 *  a successful login with an error */
typedef void (^OAServerApiUsersLoginNativeCallback)(NSDictionary *userDict, BOOL newUser, NSError *error);

/** retrieve user information after native SDK login */
@interface OAServerApiUsersLoginNative : OAServerApiBase

/**
 *  get user information with access token received from Facebook SDK
 *
 * @param token access token received from Facebook SDK. Can be retrieved using:
 * `[[[FBSession activeSession] accessTokenData] accessToken]`
 *
 * @param callback completion block called after operation has been either finished successfully or failed
 *
 * @return `false` if the request could not be created and no callback will be called, `true` on successful connection
 * initiation
 */
- (BOOL)getInfoWithFacebookToken:(NSString *)token andComplete:(OAServerApiUsersLoginNativeCallback)callback;

/**
 *  get user information with access token received from Twitter
 *
 * @param token access token received from Twitter using reverse auth
 *
 * @param secret OAuth secret receivef form Twitter using reverse auth
 *
 * @param callback completion block called after operation has been either finished successfully or failed
 *
 * @return `false` if the request could not be created and no callback will be called, `true` on successful connection
 * initiation
 *
 * @see https://github.com/seancook/TWReverseAuthExample
 */
- (BOOL)getInfoWithTwitterToken:(NSString *)token
                         secret:(NSString *)secret
                       complete:(OAServerApiUsersLoginNativeCallback)callback;

@end
