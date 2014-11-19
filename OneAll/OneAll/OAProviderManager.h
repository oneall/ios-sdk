//
//  OAProviderManager.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

@class OAProvider;

/** access to array of providers managed locally and synchronized with server */
@interface OAProviderManager : NSObject

/** array of providers maintained by manager */
@property (strong, nonatomic) NSArray *providers;

+ (instancetype)sharedInstance;

/**
 * get provider by its name
 *
 * @param providerType type of provider to lookup
 *
 * @return provider requested or `nil` if provider with specified type not found
 */
- (OAProvider *)providerWithType:(NSString *)providerType;

/** refresh names of providers */
- (void)refreshProviderNamesInBackgroundWithSubdomain:(NSString *)subdomain;

@end
