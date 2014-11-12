//
//  OASettings.h
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/** Global project settings */
@interface OASettings : NSObject

/** subdomain of the application, for example, for application at http://foo.oneal.com, the value should be 'foo' */
@property (strong, nonatomic) NSString *subdomain;

/** `true` control network activity indicator by current SDK, `false` network activity indicator is not touched by the
 * library */
@property (nonatomic) BOOL controlNetworkActivityIndicator;

+ (instancetype)sharedInstance;

@end
