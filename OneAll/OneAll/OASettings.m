//
//  OASettings.m
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OASettings.h"

@implementation OASettings

+ (instancetype)sharedInstance
{
    static OASettings *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OASettings alloc] init];
    });

    return _sharedInstance;
}

@end
