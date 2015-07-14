//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAServerApiBase.h"
#import "OAProviderManager.h"
#import "OAError.h"
#import "OAMessagePostResult.h"

/** implementation of message posting to user's wall for multiple providers */
@interface OAServerApiMessagePost : OAServerApiBase

/** post message to user's wall
 *
 * @param text text of the message to be posted
 *
 * @param pictureUrl URL of the posted image [optional]
 *
 * @param videoUrl URL of the posted video [optional]
 *
 * @param linkUrl URL appearing in the post [optional]
 *
 * @param linkName name of the posted link [optional]
 *
 * @param linkCaption caption of the posted link
 *
 * @param enableTracking should the post include OA click tracking?
 *
 * @param userToken user token received during login
 *
 * @param publishToken publish token received during connection information retrieval
 *
 * @param providers array of provider types
 *
 * @param complete callback to use on operation completion. Parameter passed to this callback will include detailed
 * information about success of posting for every provider specified in the request.
 *
 * @return `false` if the post is invalid (look in application console for issues) or `true` in the request has been
 * created and sent. For invalid post (`false` return value) callback will not be called.
 *
 * @see http://docs.oneall.com/api/resources/users/write-to-users-wall/
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

@end
