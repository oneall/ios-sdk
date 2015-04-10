//
//  OAProviderManager.m
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAProviderManager.h"
#import "OALog.h"
#import "OAServerApiProviders.h"
#import "OAProvider.h"

static NSString *const kCachedProviderNamesFielName = @"providers.plist";

@interface OAProviderManager ()

@property (strong, nonatomic) OAServerApiProviders *api;

@end

@implementation OAProviderManager

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    @try
    {
        self.providers = [NSKeyedUnarchiver unarchiveObjectWithFile:[self cachedProvidersFilePath]];
        OALog(@"Read cached provders: %@", self.providers);
    }
    @catch (NSException *e)
    {
        /* overly protective, but SDK should not crash */
        OALog(@"Failed to read cached provider names: %@, %@", e.debugDescription, e.userInfo);
    }

    return self;
}

+ (instancetype)sharedInstance
{
    static OAProviderManager *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OAProviderManager alloc] init];
    });

    return _sharedInstance;
}

- (OAProvider *)providerWithType:(NSString *)providerType
{
    for (OAProvider *p in self.providers)
    {
        if ([p.type isEqualToString:providerType])
        {
            return p;
        }
    }
    return nil;
}

- (NSString *)cachedProvidersFilePath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (paths.count == 0)
    {
        return nil;
    }

    return [paths[0] stringByAppendingPathComponent:kCachedProviderNamesFielName];
}

- (void)refreshProviderNamesInBackgroundWithSubdomain:(NSString *)subdomain
{
    self.api = [[OAServerApiProviders alloc] init];
    BOOL res = [self.api read:^(NSArray *providers, OAError *error)
    {
        if (providers == nil || error != nil)
        {
            OALog(@"Could not retrieve provider names from the server");
            return;
        }
        self.providers = providers;

        OALog(@"Read %d providers from the server", (int)self.providers.count);

        [NSKeyedArchiver archiveRootObject:self.providers toFile:[self cachedProvidersFilePath]];
    }];
    if (!res)
    {
        OALog(@"Failed to read provider names (invalid request)");
    }
}

@end
