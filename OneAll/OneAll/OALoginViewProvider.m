//
//  OALoginViewProvider.m
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OALoginViewProvider.h"

@implementation OALoginViewProvider

+ (instancetype)providerWithType:(OAProviderType)provider andName:(NSString *)name andImage:(NSString *)imageName
{
    OALoginViewProvider *rv = [[OALoginViewProvider alloc] init];
    rv.name = name;
    rv.imageName = imageName;
    rv.type = provider;
    return rv;
}

@end
