//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAUserParser.h"
#import "OAIdentity.h"

@implementation OAUserParser

+ (OAIdentityEmail *)parseIdentityEmail:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    OAIdentityEmail *eml = [[OAIdentityEmail alloc] init];
    eml.value = dict[@"value"];

    id isVerified = dict[@"is_verified"];
    if ([isVerified isKindOfClass:[NSNumber class]])
    {
        eml.isVerified = [(NSNumber *)isVerified boolValue];
    }

    return eml;
}

+ (NSArray *)parseIdentityEmails:(NSArray *)emailsArray
{
    if (![emailsArray isKindOfClass:[NSArray class]])
    {
        return nil;
    }

    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:emailsArray.count];
    [emailsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OAIdentityEmail *eml = [self parseIdentityEmail:obj];
        if (eml)
        {
            [rv addObject:eml];
        }
    }];
    return rv;
}

+ (OAIdentity *)parseIdentity:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    OAIdentity *rv = [[OAIdentity alloc] init];
    rv.identityToken = dict[@"identity_token"];
    rv.provider = dict[@"provider"];
    rv.id = dict[@"id"];
    rv.displayName = dict[@"displayName"];
    rv.gender = dict[@"gender"];
    rv.birthday = dict[@"birthday"];
    rv.utcOffset = dict[@"utcOffset"];
    rv.preferredUsername = dict[@"preferredUsername"];

    rv.pictureUrl = dict[@"pictureUrl"] && (dict[@"pictureUrl"] != (id)[NSNull null]) ?
        [NSURL URLWithString:dict[@"pictureUrl"]] : nil;

    rv.emails = [self parseIdentityEmails:dict[@"emails"]];

    NSDictionary *nameDict = dict[@"name"];
    if ([nameDict isKindOfClass:[NSDictionary class]])
    {
        rv.formattedName = nameDict[@"formatted"];
        rv.givenName = nameDict[@"givenName"];
        rv.familyName = nameDict[@"familyName"];
    }

    return rv;
}

+ (NSArray *)parseIdentities:(NSArray *)identitiesDict
{
    if (![identitiesDict isKindOfClass:[NSArray class]])
    {
        return nil;
    }

    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:identitiesDict.count];
    [identitiesDict enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OAIdentity *identity = [self parseIdentity:obj];
        if (identity)
        {
            [rv addObject:identity];
        }
    }];
    return rv;
}

+ (OAUser *)parseUser:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    OAUser *user = [[OAUser alloc] init];

    user.uuid = dict[@"uuid"];
    user.userToken = dict[@"user_token"];
    user.publishToken = [self parsePublishToken:dict[@"publish_token"]];
    
    if (dict[@"identity"] && !dict[@"identities"])
    {
        user.identity = [self parseIdentity:dict[@"identity"]];
        user.identities = @[user.identity];
    }
    else
    {
        user.identities = [self parseIdentities:dict[@"identities"]];
        user.identity = [self parseIdentity:dict[@"identity"]];
    }

    if (user.identity)
    {
        user.displayName = user.identity.displayName;
        user.givenName = user.identity.givenName;
        user.familyName = user.identity.familyName;
        user.pictureUrl = user.identity.pictureUrl;
    }

    user.managedObject = dict;

    return user;
}

+ (NSDate *)parseDate:(NSString *)strDate
{
    static NSDateFormatter *dateFormatter;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setLocale:[NSLocale localeWithLocaleIdentifier:@"en_US"]];
        [dateFormatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss z"];
    });

    if (strDate == nil || strDate == (id)[NSNull null])
    {
        return nil;
    }

    return [dateFormatter dateFromString:strDate];
}

+ (OAUserPublishToken *)parsePublishToken:(NSDictionary *)dict
{
    if (![dict isKindOfClass:[NSDictionary class]])
    {
        return nil;
    }

    return [OAUserPublishToken tokenWithKey:dict[@"key"]
                               creationDate:[OAUserParser parseDate:dict[@"date_creation"]]
                             expirationDate:[OAUserParser parseDate:dict[@"date_expiration"]]];
}

@end
