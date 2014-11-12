//
//  OAProvider.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/** types of all supported providers */
typedef NS_ENUM(NSInteger, OAProviderType)
{
    OA_PROVIDER_NONE = 0,
    OA_PROVIDER_AMAZON,
    OA_PROVIDER_BLOGGER,
    OA_PROVIDER_DISQUS,
    OA_PROVIDER_FACEBOOK,
    OA_PROVIDER_FOURSQUARE,
    OA_PROVIDER_GITHUB,
    OA_PROVIDER_GOOGLE,
    OA_PROVIDER_INSTAGRAM,
    OA_PROVIDER_LINKEDIN,
    OA_PROVIDER_LIVEJOURNAL,
    OA_PROVIDER_MAILRU,
    OA_PROVIDER_ODNOKLASSNIKI,
    OA_PROVIDER_OPENID,
    OA_PROVIDER_PAYPAL,
    OA_PROVIDER_REDDIT,
    OA_PROVIDER_SKYROCK,
    OA_PROVIDER_STACKEXCHANGE,
    OA_PROVIDER_STEAM,
    OA_PROVIDER_TWITCH,
    OA_PROVIDER_TWITTER,
    OA_PROVIDER_VIMEO,
    OA_PROVIDER_VKONTAKTE,
    OA_PROVIDER_WINDOWSLIVE,
    OA_PROVIDER_WORDPRESS,
    OA_PROVIDER_YAHOO,
    OA_PROVIDER_YOUTUBE
};

/** service methods to convert between provider types and their names */
@interface OAProvider : NSObject
+ (instancetype)sharedInstance;

/**
* get provider name for specified provider type
* @param provider provider type
* @return name of the provider
*/
- (NSString *)providerName:(OAProviderType)provider;

/**
 * parse provider type from its string representation
 *
 * @param providerName name of the provider in OneAll format
 *
 * @return type of the provider or `OA_PROVIDER_NONE` if could not be parsed
 */
- (OAProviderType)providerWithName:(NSString *)providerName;

@end
