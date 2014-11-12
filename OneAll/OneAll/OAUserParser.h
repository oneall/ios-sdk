//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAUser.h"

/** utility class with user parsing helper */
@interface OAUserParser : NSObject

/**
 * parse the user from the JSON parsed object received from OA server
 *
 * @param dict dictionary with user object. This should be the contents of `user` JSON field of the response.
 *
 * @see http://docs.oneall.com/api/resources/connections/read-connection-details/
 */
+ (OAUser *)parseUser:(NSDictionary *)dict;

@end
