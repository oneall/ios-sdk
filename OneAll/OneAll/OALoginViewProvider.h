//
//  OALoginViewProvider.h
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAProviderManager.h"

/** simple data holder with provider type, name, and corresponding provider icon */
@interface OALoginViewProvider : NSObject

@property (strong, nonatomic) NSString *imageName;
@property (strong, nonatomic) OAProvider *provider;
@property (nonatomic) NSInteger tag;

+ (instancetype)provider:(OAProvider *)provider image:(NSString *)imageName tag:(NSInteger)tag;

@end
