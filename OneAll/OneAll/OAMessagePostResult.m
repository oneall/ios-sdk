//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAMessagePostResult.h"

@implementation OAMessagePostResult

- (NSString *)description
{
    NSMutableString *rv = [NSMutableString stringWithFormat:@"<%@: ", NSStringFromClass([self class])];

    [self.providerResults enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (idx)
        {
            [rv appendString:@","];
        }
        [rv appendFormat:@"%@\r", [obj description]];
    }];

    [rv appendString:@">"];
    return rv;
}

@end

@implementation OAMessagePostProviderResult

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: success=%@, flag=%@, code=%d, provider=%@, '%@'>",
                                      NSStringFromClass([self class]),
                                      self.success ? @"YES" : @"NO",
                                      self.flag,
                                      (int)self.code,
                                      self.provider,
                                      self.message];
}

@end
