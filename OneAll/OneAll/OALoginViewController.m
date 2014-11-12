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
    return [super initWithNibName:NSStringFromClass(self.class) bundle:[OABundle libraryResourcesBundle]];
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
        prv = @[
                [OALoginViewProvider providerWithType:OA_PROVIDER_AMAZON andName:@"Amazon" andImage:@"button-login-amazon"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_BLOGGER andName:@"Blogger" andImage:@"button-login-blogger"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_DISQUS andName:@"Disqus" andImage:@"button-login-disqus"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_FACEBOOK andName:@"Facebook" andImage:@"button-login-facebook"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_FOURSQUARE andName:@"Foursquare" andImage:@"button-login-foursquare"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_GITHUB andName:@"GitHub" andImage:@"button-login-github"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_GOOGLE andName:@"Google" andImage:@"button-login-google"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_INSTAGRAM andName:@"Instagram" andImage:@"button-login-instagram"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_LINKEDIN andName:@"LinkedIn" andImage:@"button-login-linkedin"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_LIVEJOURNAL andName:@"LiveJournal" andImage:@"button-login-livejournal"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_MAILRU andName:@"Mail.Ru" andImage:@"button-login-mailru"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_ODNOKLASSNIKI andName:@"Odnoklassniki" andImage:@"button-login-odnoklassniki"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_OPENID andName:@"OpenID" andImage:@"button-login-openid"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_PAYPAL andName:@"PayPal" andImage:@"button-login-paypal"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_REDDIT andName:@"Reddit" andImage:@"button-login-reddit"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_SKYROCK andName:@"SkyRock" andImage:@"button-login-skyrock"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_STACKEXCHANGE andName:@"StackExchange" andImage:@"button-login-stackexchange"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_STEAM andName:@"Steam" andImage:@"button-login-steam"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_TWITCH andName:@"Twitch" andImage:@"button-login-twitch"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_TWITTER andName:@"Twitter" andImage:@"button-login-twitter"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_VIMEO andName:@"Vimeo" andImage:@"button-login-vimeo"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_VKONTAKTE andName:@"VKontakte" andImage:@"button-login-vkontakte"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_WINDOWSLIVE andName:@"Windows Live" andImage:@"button-login-windowslive"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_WORDPRESS andName:@"Wordpress" andImage:@"button-login-wordpress"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_YAHOO andName:@"Yahoo!" andImage:@"button-login-yahoo"],
                [OALoginViewProvider providerWithType:OA_PROVIDER_YOUTUBE andName:@"YouTube" andImage:@"button-login-youtube"]
                ];
    });
    return prv;
}

/* setting up the newly created cell */
- (void)configureCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    OALoginViewProvider *prov = [OALoginViewController providers][(NSUInteger) indexPath.row];

    cell.imageView.image = [OABundle imageNamed:prov.imageName];
    cell.textLabel.text = prov.name;
    cell.tag = prov.type;
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
    OALog(@"Selected provider at index %@ with tag %d", indexPath, (int)cell.tag);
    [self.actionDelegate oaLoginController:self selectedMethod:(OAProviderType) cell.tag];
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
