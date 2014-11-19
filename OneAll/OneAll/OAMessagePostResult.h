//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAProviderManager.h"
#import "OAError.h"

/** result of message posing for single provider */
@interface OAMessagePostProviderResult : NSObject
@property (nonatomic) BOOL success;
@property (strong, nonatomic) NSString *flag;
@property (nonatomic) NSInteger code;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *provider;
@end

/** result of message posting. Contains results for multiple providers as well as original returned dictionary */
@interface OAMessagePostResult : NSObject
@property (strong, nonatomic) NSDictionary *wholeResponse;
@property (strong, nonatomic) NSString *messageToken;
@property (strong, nonatomic) NSArray *providerResults;
@end

/** callback used to inform the caller about post operation completion */
typedef void (^OAMessagePostCallback)(BOOL failed, OAMessagePostResult *result, OAError *error);
