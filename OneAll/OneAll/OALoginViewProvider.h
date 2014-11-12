//
//  OALoginViewProvider.h
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAProvider.h"

/** simple data holder with provider type, name, and corresponding provider icon */
@interface OALoginViewProvider : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *imageName;
@property (nonatomic) OAProviderType type;

+ (instancetype)providerWithType:(OAProviderType)provider andName:(NSString *)name andImage:(NSString *)imageName;

@end
