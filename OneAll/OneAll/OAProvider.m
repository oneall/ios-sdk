//
// Created by Uri Kogan on 19/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAProvider.h"

static NSString *const kEncFieldType = @"kEncFieldType";
static NSString *const kEncFieldName = @"kEncFieldName";
static NSString *const kEncFieldUserInputRequired = @"kEncFieldUserInputRequired";
static NSString *const kEncFieldUserInputTitle = @"kEncFieldUserInputTitle";
static NSString *const kEncFieldIsConfigured = @"kEncFieldIsConfigured";
static NSString *const kEncFieldIsConfigurationRequired = @"kEncFieldIsConfigurationRequired";

@implementation OAProvider

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.type forKey:kEncFieldType];
    [coder encodeObject:self.name forKey:kEncFieldName];
    [coder encodeBool:self.userInputRequired forKey:kEncFieldUserInputRequired];
    [coder encodeBool:self.isConfigured forKey:kEncFieldIsConfigured];
    [coder encodeBool:self.isConfigurationRequired forKey:kEncFieldIsConfigurationRequired];
    [coder encodeObject:self.userInputTitle forKey:kEncFieldUserInputTitle];
}

- (id)initWithCoder:(NSCoder *)coder
{
    self = [self init];
    if (self)
    {
        _type = [coder decodeObjectForKey:kEncFieldType];
        _name = [coder decodeObjectForKey:kEncFieldName];
        _userInputRequired = [coder decodeBoolForKey:kEncFieldUserInputRequired];
        _isConfigured = [coder decodeBoolForKey:kEncFieldIsConfigured];
        _isConfigurationRequired = [coder decodeBoolForKey:kEncFieldIsConfigurationRequired];
        _userInputTitle = [coder decodeObjectForKey:kEncFieldUserInputTitle];
    }
    return self;
}

+ (instancetype)providerType:(NSString *)type
                        name:(NSString *)name
                isConfigured:(BOOL)isConfigured
     isConfigurationRequired:(BOOL)isConfigurationRequired
           userInputRequired:(BOOL)userInputRequired
              userInputTitle:(NSString *)userInputTitle
{
    OAProvider *rv = [[OAProvider alloc] init];
    rv.type = type;
    rv.name = name;
    rv.userInputRequired = userInputRequired;
    rv.userInputTitle = userInputTitle;
    rv.isConfigured = isConfigured;
    rv.isConfigurationRequired = isConfigurationRequired;
    return rv;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%@: %@, name=%@, config=%d/%d%@>",
                                      NSStringFromClass(self.class),
                                      self.type,
                                      self.name,
                                      self.isConfigured,
                                      self.isConfigurationRequired,
                                      self.userInputRequired ? [NSString stringWithFormat:@", %@", self.userInputTitle] : @""];
}

@end
