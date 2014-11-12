//
//  OAProvider.m
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAProvider.h"

@interface OAProvider ()
@property (strong, nonatomic) NSDictionary *dict;
@property (strong, nonatomic) NSDictionary *inverseDict;
@end

@implementation OAProvider

- (id)init
{
    self = [super init];
    if (!self)
    {
        return nil;
    }

    _dict = @{
              @(OA_PROVIDER_AMAZON): @"amazon",
              @(OA_PROVIDER_BLOGGER): @"blogger",
              @(OA_PROVIDER_DISQUS): @"disqus",
              @(OA_PROVIDER_FACEBOOK): @"facebook",
              @(OA_PROVIDER_FOURSQUARE): @"foursquare",
              @(OA_PROVIDER_GITHUB): @"github",
              @(OA_PROVIDER_GOOGLE): @"google",
              @(OA_PROVIDER_INSTAGRAM): @"instagram",
              @(OA_PROVIDER_LINKEDIN): @"linkedin",
              @(OA_PROVIDER_LIVEJOURNAL): @"livejournal",
              @(OA_PROVIDER_MAILRU): @"mailru",
              @(OA_PROVIDER_ODNOKLASSNIKI): @"odnoklassniki",
              @(OA_PROVIDER_OPENID): @"openid",
              @(OA_PROVIDER_PAYPAL): @"paypal",
              @(OA_PROVIDER_REDDIT): @"reddit",
              @(OA_PROVIDER_SKYROCK): @"skyrock",
              @(OA_PROVIDER_STACKEXCHANGE): @"stackexchange",
              @(OA_PROVIDER_STEAM): @"steam",
              @(OA_PROVIDER_TWITCH): @"twitch",
              @(OA_PROVIDER_TWITTER): @"twitter",
              @(OA_PROVIDER_VIMEO): @"vimeo",
              @(OA_PROVIDER_VKONTAKTE): @"vkontakte",
              @(OA_PROVIDER_WINDOWSLIVE): @"windowslive",
              @(OA_PROVIDER_WORDPRESS): @"wordpress",
              @(OA_PROVIDER_YAHOO): @"yahoo",
              @(OA_PROVIDER_YOUTUBE): @"youtube"
             };

    _inverseDict = [NSDictionary dictionaryWithObjects:[_dict allKeys] forKeys:[_dict allValues]];

    return self;
}

+ (instancetype)sharedInstance
{
    static OAProvider *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[OAProvider alloc] init];
    });

    return _sharedInstance;
}

- (NSString *)providerName:(OAProviderType)provider
{
    return self.dict[@(provider)];
}

- (OAProviderType)providerWithName:(NSString *)providerName
{
    return (OAProviderType) [self.inverseDict[providerName] integerValue];
}

@end
