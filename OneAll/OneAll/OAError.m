//
//  NSError+OA.m
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAError.h"

static NSString *const kErrorDomain = @"OneAllErrorDomain";

@implementation OAError

+ (OAError *)errorWithMessage:(NSString *)message andCode:(OAErrorCode)code
{
    return [OAError errorWithDomain:kErrorDomain
                               code:code
                           userInfo:@{ NSLocalizedDescriptionKey: NSLocalizedString(message, nil) }];
}

+ (OAError *)errorWithError:(NSError *)error
{
    return [OAError errorWithMessage:error.localizedDescription andCode:(OAErrorCode) error.code];
}

@end
