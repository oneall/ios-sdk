//
// Created by Uri Kogan on 7/21/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAProviderManager.h"

/** email object which is a part of the OAIdentity object returned by OneAll server */
@interface OAIdentityEmail : NSObject
@property (strong, nonatomic) NSString *value;
@property (nonatomic) BOOL isVerified;
@end

/** identity which is part of the user object returned by OneAll server */
@interface OAIdentity : NSObject

@property (strong, nonatomic) NSString *identityToken;
@property (strong, nonatomic) NSString *provider;
@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *displayName;
@property (strong, nonatomic) NSString *formattedName;
@property (strong, nonatomic) NSString *givenName;
@property (strong, nonatomic) NSString *familyName;
@property (strong, nonatomic) NSString *gender;
@property (strong, nonatomic) NSString *birthday;
@property (strong, nonatomic) NSString *utcOffset;
@property (strong, nonatomic) NSArray *emails;
@property (strong, nonatomic) NSString *preferredUsername;
@property (strong, nonatomic) NSURL *pictureUrl;

@end
