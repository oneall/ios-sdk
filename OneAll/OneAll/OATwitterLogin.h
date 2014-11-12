//
// Created by Uri Kogan on 10/8/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/**
 * Twitter login and reverse authentication callback
 *
 * @param oauthToken OAuth token recevied from Twitter on reverse authentication
 *
 * @param secret OAuth secret received from Twitter on reverse authentication
 */
typedef void (^OATwitterLoginCallback)(NSString *oauthToken, NSString *secret);

/** implementation ot native Twitter authentication (built into iOS6 and later). Using this  */
@interface OATwitterLogin : NSObject

+ (instancetype)sharedInstance;

/** can the native Twitter authentication be used? Native Twitter auth can be used only if it has been setup previously
 * with Twitter consumer key and secret using `setConsumerKey:andSecret` of this class. */
- (BOOL)canBeUsed;

/**
 * consumer key and consumer secret of Twitter application
 *
 * @param key consumer key of Twitter application
 *
 * @param secret consumer secret of Twitter application
 *
 * @see https://apps.twitter.com/
*/
- (void)setConsumerKey:(NSString *)key andSecret:(NSString *)secret;

/**
 * login using native Twitter auth, retrieve user access token and message the caller via callback
 *
 * @param callback callback method used to message the caller about operation completion. May be nil
 *
 * @return `false` if the request could not have been made (Twitter auth cannot be used) or `true` if the request has
 * been created. in case of `false` return value callback of the method will not be called. */
- (BOOL)login:(OATwitterLoginCallback)callback;

@end
