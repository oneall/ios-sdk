//
//  OALoginViewController.m
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OALoginViewController.h"
#import "OALoginViewProvider.h"
#import "OABundle.h"
#import "OALog.h"
#import "OAProvider.h"
#import <QuartzCore/QuartzCore.h>

static NSString *const kCellIdentifier = @"oaProvCell";

/** row height of login cell */
static const CGFloat kRowHeight = 55.f;

@interface OALoginViewController () <UITableViewDataSource, UITableViewDelegate>

/** delegate used to inform the caller about events in this controller */
@property (weak, nonatomic) id<OALoginControllerDelegate> actionDelegate;

@end

@implementation OALoginViewController
{
    dispatch_once_t _onceToken;
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    OALog(@"");
    [super viewDidLoad];
    [self setupNavbar];
    self.automaticallyAdjustsScrollViewInsets = false;
}


/** this method is required in order to specify different bundle other than the main one, as the XIB file sits in static
 * library bundle and not the main one */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:NSStringFromClass(self.class) bundle:[OABundle libraryResourcesBundle]];
    if (self)
    {
        _userToken = nil;
        _action = OASocialLinkActionNone;
    }
    return self;
}

- (id)initWithDelegate:(id<OALoginControllerDelegate>)delegate
{
    self = [self init];
    if (self)
    {
        _actionDelegate = delegate;
    }
    return self;
}

#pragma mark - Appearance and setup

/** setup the navigation bar of this controller */
- (void)setupNavbar
{
    self.navigationItem.leftBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
                                     style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(handleButtonCancel:)];
}

/** create and initialize array of all possible providers and their corresponding button images */
+ (NSArray *)providers
{
    static dispatch_once_t onceToken;
    static NSArray *prv;
    dispatch_once(&onceToken, ^{
        NSArray *allProviders = @[
                @"amazon",
                @"blogger",
                @"disqus",
                @"facebook",
                @"foursquare",
                @"github",
                @"google",
                @"instagram",
                @"linkedin",
                @"livejournal",
                @"mailru",
                @"odnoklassniki",
                @"openid",
                @"paypal",
                @"reddit",
                @"skyrock",
                @"stackexchange",
                @"steam",
                @"twitch",
                @"twitter",
                @"vimeo",
                @"vkontakte",
                @"windowslive",
                @"wordpress",
                @"yahoo",
                @"youtube"];
        NSMutableArray *tarr = [NSMutableArray array];
        [allProviders enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
        {
            OAProvider *p = [[OAProviderManager sharedInstance] providerWithType:obj];
            if (p != nil && (!p.isConfigurationRequired || p.isConfigured))
            {
                [tarr addObject:[OALoginViewProvider provider:p image:[self imageNameForProviderType:p.type] tag:idx]];

            }
        }];
        prv = [NSArray arrayWithArray:tarr];
    });
    return prv;
}

+ (NSString *)imageNameForProviderType:(NSString *)providerType
{
    if ([providerType isEqualToString:@"amazon"]) return @"button-login-amazon";
    if ([providerType isEqualToString:@"blogger"]) return @"button-login-blogger";
    if ([providerType isEqualToString:@"disqus"]) return @"button-login-disqus";
    if ([providerType isEqualToString:@"facebook"]) return @"button-login-facebook";
    if ([providerType isEqualToString:@"foursquare"]) return @"button-login-foursquare";
    if ([providerType isEqualToString:@"github"]) return @"button-login-github";
    if ([providerType isEqualToString:@"google"]) return @"button-login-google";
    if ([providerType isEqualToString:@"instagram"]) return @"button-login-instagram";
    if ([providerType isEqualToString:@"linkedin"]) return @"button-login-linkedin";
    if ([providerType isEqualToString:@"livejournal"]) return @"button-login-livejournal";
    if ([providerType isEqualToString:@"mailru"]) return @"button-login-mailru";
    if ([providerType isEqualToString:@"odnoklassniki"]) return @"button-login-odnoklassniki";
    if ([providerType isEqualToString:@"openid"]) return @"button-login-openid";
    if ([providerType isEqualToString:@"paypal"]) return @"button-login-paypal";
    if ([providerType isEqualToString:@"reddit"]) return @"button-login-reddit";
    if ([providerType isEqualToString:@"skyrock"]) return @"button-login-skyrock";
    if ([providerType isEqualToString:@"stackexchange"]) return @"button-login-stackexchange";
    if ([providerType isEqualToString:@"steam"]) return @"button-login-steam";
    if ([providerType isEqualToString:@"twitch"]) return @"button-login-twitch";
    if ([providerType isEqualToString:@"twitter"]) return @"button-login-twitter";
    if ([providerType isEqualToString:@"vimeo"]) return @"button-login-vimeo";
    if ([providerType isEqualToString:@"vkontakte"]) return @"button-login-vkontakte";
    if ([providerType isEqualToString:@"windowslive"]) return @"button-login-windowslive";
    if ([providerType isEqualToString:@"wordpress"]) return @"button-login-wordpress";
    if ([providerType isEqualToString:@"yahoo"]) return @"button-login-yahoo";
    if ([providerType isEqualToString:@"youtube"]) return @"button-login-youtube";
    return nil;
}

/* setting up the newly created cell */
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    OALoginViewProvider *prov = [OALoginViewController providers][(NSUInteger) indexPath.row];

    cell.imageView.image = [OABundle imageNamed:prov.imageName];
    cell.textLabel.text = prov.provider.name;
    cell.tag = prov.tag;
}

- (OALoginViewProvider *)findProviderWithTag:(NSInteger)tag
{
    for (OALoginViewProvider *lp in [OALoginViewController providers])
    {
        if (lp.tag == tag)
        {
            return lp;
        }
    }
    return nil;
}

#pragma mark - UI handlers

/** "Cancel" button handler */
- (void)handleButtonCancel:(id)sender
{
    OALog(@"");
    [self.actionDelegate oaLoginControllerCancelled:self];
}

#pragma mark - UITableViewDelegate

/** handler of selection of one of the authentication methods */
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    /* first of all clear the selection */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];

    OALoginViewProvider *provider = [self findProviderWithTag:cell.tag];

    OALog(@"Selected provider at index %@: %@", indexPath, provider.provider.type);

    [self.actionDelegate oaLoginController:self selectedMethod:provider.provider];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRowHeight;
}

/* number of rows in the table is as the number of possible providers */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[OALoginViewController providers] count];
}

/* build a row with a single provider type */
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    dispatch_once(&_onceToken, ^{
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    });

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }

    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

#pragma mark - Interface methods

+ (OALoginViewController *)showWithDelegate:(id<OALoginControllerDelegate>)delegate
{
    OALog(@"");
    OALoginViewController *vc = [[OALoginViewController alloc] initWithDelegate:delegate];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    UIViewController *rootVc = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
    [rootVc presentViewController:nav animated:YES completion:nil];

    return vc;
}

+ (OALoginViewController *)showInContainer:(UIViewController *)parentVc
                              withDelegate:(id<OALoginControllerDelegate>)delegate
{
    OALog(@"");
    OALoginViewController *vc = [[OALoginViewController alloc] initWithDelegate:delegate];
    [parentVc presentViewController:vc animated:YES completion:nil];
    return vc;
}

@end
