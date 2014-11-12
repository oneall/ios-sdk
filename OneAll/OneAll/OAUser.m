//
//  OAUser.m
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAUser.h"

@implementation OAUserPublishToken

- (id)initWithKey:(NSString *)key creationDate:(NSDate *)creationDate expirationDate:(NSDate *)expirationDate
{
    self = [self init];
    if (self)
    {
        _key = key;
        _dateCreation = creationDate;
        _dateExipration = expirationDate;
    }
    return self;
}

+ (instancetype)tokenWithKey:(NSString *)key creationDate:(NSDate *)creationDate expirationDate:(NSDate *)expirationDate
{
    return [[OAUserPublishToken alloc] initWithKey:key creationDate:creationDate expirationDate:expirationDate];
}

@end

@implementation OAUser
@end
