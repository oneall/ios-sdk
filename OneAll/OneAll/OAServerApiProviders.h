//
// Created by Uri Kogan on 19/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAServerApiBase.h"
#import "OAError.h"

typedef void (^OAServerApiProvidersCallback)(NSArray *providers, OAError *error);

@interface OAServerApiProviders : OAServerApiBase
- (BOOL)read:(OAServerApiProvidersCallback)callback;
@end