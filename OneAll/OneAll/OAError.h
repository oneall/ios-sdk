//
//  NSError+OA.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/** types of errors */
typedef NS_ENUM(NSInteger, OAErrorCode)
{
    OA_ERROR_CANCELLED,
    OA_ERROR_INVALID_REQUEST,
    OA_ERROR_AUTH_FAIL,
    OA_ERROR_MESSAGE_POST_FAIL,
    OA_ERROR_TIMEOUT,
    OA_ERROR_CONNECTION_ERROR
};

@interface OAError : NSError

/** create an error object and initialize it with specifeid message and error code */
+ (OAError *)errorWithMessage:(NSString *)message andCode:(OAErrorCode)code;

/** create an error object and copy the message and error code fro supplied error */
+ (OAError *)errorWithError:(NSError *)error;

@end
