//
// Created by Uri Kogan on 3/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "OANetworkActivityIndicatorControl.h"
#import "OALog.h"
#import "OASettings.h"

@interface OANetworkActivityIndicatorControl ()
@property (nonatomic) NSInteger counter;
@end

@implementation OANetworkActivityIndicatorControl

- (id)init
{
    self = [super init];
    if (self)
    {
        _counter = 0;
    }
    return self;
}

+ (instancetype)sharedInstance
{
    static OANetworkActivityIndicatorControl *instance;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        instance = [[OANetworkActivityIndicatorControl alloc] init];
    });
    return instance;
}

- (void)turnOn
{
    self.counter ++;

    if ([[OASettings sharedInstance] controlNetworkActivityIndicator])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:true];
        });
    }
}

- (void)turnOff
{
    self.counter --;
    if (self.counter < 0)
    {
        OALog(@"negative activity counter");
        self.counter = 0;
    }

    if (self.counter > 0)
    {
        return;
    }

    if ([[OASettings sharedInstance] controlNetworkActivityIndicator])
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
        });
    }
}

- (void)takeControl
{
    [[OASettings sharedInstance] setControlNetworkActivityIndicator:true];
}

- (void)releaseControl
{
    [[OASettings sharedInstance] setControlNetworkActivityIndicator:false];
    if (self.counter > 0)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:false];
        });
    }
}

@end
