//
// Created by Uri Kogan on 19/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface OAProvider : NSObject<NSCoding>

@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *name;
@property (nonatomic) BOOL userInputRequired;
@property (nonatomic, strong) NSString *userInputTitle;
@property (nonatomic) BOOL isConfigured;
@property (nonatomic) BOOL isConfigurationRequired;

+ (instancetype)providerType:(NSString *)type
                        name:(NSString *)name
                isConfigured:(BOOL)isConfigured
     isConfigurationRequired:(BOOL)isConfigurationRequired
           userInputRequired:(BOOL)userInputRequired
              userInputTitle:(NSString *)userInputTitle;

@end