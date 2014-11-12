//
// Created by Uri Kogan on 3/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

/** controller of library wide activity indicator (UIActivityIndicator) */
@interface OANetworkActivityIndicatorControl : NSObject

+ (instancetype)sharedInstance;

/** turn on indicator and increase reference counter */
- (void)turnOn;

/** decrease reference counter and if reaches zero, turn off activity indicator */
- (void)turnOff;

/** take control of activity indicator */
- (void)takeControl;

/** release control of acivity indicator back to the user */
- (void)releaseControl;

@end