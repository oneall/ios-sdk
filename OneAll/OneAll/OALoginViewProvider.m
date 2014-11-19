//
//  OALoginViewProvider.m
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OALoginViewProvider.h"
#import "OAProvider.h"

@implementation OALoginViewProvider

+ (instancetype)provider:(OAProvider *)provider image:(NSString *)imageName tag:(NSInteger)tag
{
    OALoginViewProvider *rv = [[OALoginViewProvider alloc] init];
    rv.imageName = imageName;
    rv.provider = provider;
    rv.tag = tag;
    return rv;
}

@end
