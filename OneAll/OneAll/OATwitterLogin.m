//
// Created by Uri Kogan on 10/8/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OATwitterLogin.h"
#import "TWTAPIManager.h"
#import "OALog.h"

@import Accounts;

@interface OATwitterLogin ()

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) NSArray *accounts;
@property (nonatomic, strong) TWTAPIManager *apiManager;


@end

@implementation OATwitterLogin

- (id)init
{
    self = [super init];
    if (self)
    {
        _accountStore = [[ACAccountStore alloc] init];
        _apiManager = [[TWTAPIManager alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken = 0;
    static OATwitterLogin *instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [[OATwitterLogin alloc] init];
    });
    return instance;
}


- (void)setConsumerKey:(NSString *)key andSecret:(NSString *)secret
{
    self.apiManager.consumerKey = key;
    self.apiManager.consumerSecret = secret;
}

- (BOOL)canBeUsed
{
    if (self.apiManager.consumerKey == nil || self.apiManager.consumerSecret == nil)
    {
        return false;
    }

    if (![TWTAPIManager isLocalTwitterAccountAvailable])
    {
        return false;
    }

    return true;
}

- (NSDictionary *)parseToken:(NSString *)urlString
{
    NSArray *urlComponents = [urlString componentsSeparatedByString:@"&"];
    NSMutableDictionary *queryStringDictionary = [NSMutableDictionary dictionaryWithCapacity:urlComponents.count];

    for (NSString *keyValuePair in urlComponents)
    {
        NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
        NSString *key = [pairComponents objectAtIndex:0];
        NSString *value = [pairComponents objectAtIndex:1];
        
        [queryStringDictionary setObject:value forKey:key];
    }
    return queryStringDictionary;
}

- (BOOL)login:(OATwitterLoginCallback)callback
{
    if (![self canBeUsed])
    {
        return false;
    }

    __weak OATwitterLogin *wself = self;
    void (^handler)(BOOL) = ^(BOOL granted) {
        if (!granted && callback != nil)
        {
            OALogError(@"Permissions have not been granted");
            callback(nil, nil);
        }

        OALog(@"Performing reverse auth for account %@", self.accounts[0]);

        /* perform reverse auth for first found Twitter account */
        [wself.apiManager performReverseAuthForAccount:self.accounts[0] withHandler:^(NSData *responseData, NSError *error) {
            if (responseData)
            {
                NSString *responseStr = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
                OALog(@"Got access token: %@", responseStr);
                NSDictionary *dict = [self parseToken:responseStr];
                callback(dict[@"oauth_token"], dict[@"oauth_token_secret"]);
            }
            else
            {
                OALogError(@"Reverse Auth process failed. Error returned was: %@\n", [error localizedDescription]);
                callback(nil, nil);
            }
        }];
    };

    [self requestPermissions:handler];

    return true;
}

/* request local permissions for Twitter account */
- (void)requestPermissions:(void(^)(BOOL))callback
{
    ACAccountType *twType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    OALog(@"Requesting permissions for account: %@", twType);
    [self.accountStore requestAccessToAccountsWithType:twType options:NULL completion:^(BOOL granted, NSError *error) {
        if (granted)
        {
            self.accounts = [_accountStore accountsWithAccountType:twType];
        }

        OALog(@"Permissions request result: %@ (error=%@). Resulting accounts: %@",
            granted ? @"true" : @"false", error, self.accounts);

        callback(granted);
    }];
}

@end
