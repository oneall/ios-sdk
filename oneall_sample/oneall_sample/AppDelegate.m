//
//  AppDelegate.m
//  oneall_sample
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "AppDelegate.h"
#import "OAMainViewController.h"
#import <OneAll/OAMAnager.h>

static NSString *const fbAppId = nil;
static NSString *const twitterConsumerKey = nil;
static NSString *const twitterConsumerSecret = nil;

static NSString *const kOneAllSubdomain = nil;
static NSString *const kFacebookAppId = nil;
static NSString *const kTwitterConsumerKey = nil;
static NSString *const kTwitterConsumerSecret = nil;
static NSString *const kLeLogToken = @"241d9e8d-4054-431a-a600-27d36c49b107";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [[LELog sharedInstance] setToken:kLeLogToken];
    [[LELog sharedInstance] log:@"starting up"];

    if (kOneAllSubdomain.length == 0) {
        [NSException raise:NSGenericException
                    format:@"Set kOneAllSubdomain constant to your application subdomain"
                 arguments:nil];
    }
    if (kFacebookAppId.length == 0) {
        [NSException raise:NSGenericException
                    format:@"Set kFacebookAppId constant to your application subdomain"
                 arguments:nil];
    }

    [[OAManager sharedInstance] setupWithSubdomain:kOneAllSubdomain
                                     facebookAppId:kFacebookAppId
                                twitterConsumerKey:kTwitterConsumerKey
                                     twitterSecret:kTwitterConsumerSecret];

    [[OAManager sharedInstance] setNetworkActivityIndicatorControlledByOa:true];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    OAMainViewController *vc = [[OAMainViewController alloc] init];

    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

    self.window.rootViewController = nav;

    [self.window makeKeyAndVisible];

    [self setupApplicationVersion];

    return YES;
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[OAManager sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[OAManager sharedInstance] didBecomeActive];
}

- (void)setupApplicationVersion
{
    NSString *version = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    [[NSUserDefaults standardUserDefaults] setObject:version forKey:@"app_version"];
}

@end
