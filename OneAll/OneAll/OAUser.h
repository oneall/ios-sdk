//
//  OAUser.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAIdentity.h"

/** publish token returned by OA server when reading connection information */
@interface OAUserPublishToken : NSObject

@property (strong, nonatomic) NSString *key;
@property (strong, nonatomic) NSDate *dateCreation;
@property (strong, nonatomic) NSDate *dateExipration;

+ (instancetype)tokenWithKey:(NSString *)key
                creationDate:(NSDate *)creationDate
              expirationDate:(NSDate *)expirationDate;

@end

/** client representation of server side user object returned via connection retrieval endpoints */
@interface OAUser : NSObject

@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *givenName;
@property (strong, nonatomic) NSString *familyName;
@property (strong, nonatomic) NSURL *pictureUrl;

@property (strong, nonatomic) NSString *userToken;
@property (strong, nonatomic) OAUserPublishToken *publishToken;
@property (strong, nonatomic) NSString *uuid;

@property (strong, nonatomic) NSArray *identities;

@property (strong, nonatomic) OAIdentity *identity;

@property (strong, nonatomic) NSDictionary *managedObject;

@end
