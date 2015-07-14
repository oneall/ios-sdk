//
//  OAMainViewController.m
//  oneall_sample
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAMainViewController.h"
#import <OneAll/OAManager.h>
#import "OAShareViewController.h"


static NSString *const kProviderFacebook = @"facebook";
static NSString *const kProviderGoogle = @"google";
static NSString *const kProviderFoursquare = @"foursquare";

static NSString *const kCellIdentifier = @"OAMainSampleViewCell";

@interface OAMainViewController () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UIView *viewUser;
@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imageViewAvatar;
@property (weak, nonatomic) IBOutlet UILabel *labelHello;
@property (weak, nonatomic) IBOutlet UISwitch *switchSocialLinkEnable;
@property (weak, nonatomic) IBOutlet UILabel *labelSocialLinkAction;
@property (weak, nonatomic) IBOutlet UISwitch *switchSocialLinkAction;
@property (weak, nonatomic) IBOutlet UIView *viewSocialLinkAction;

@property (strong, nonatomic) OAUser *lastUser;

@end

@implementation OAMainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.rightBarButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share", @"")
                                         style:UIBarButtonItemStylePlain
                                        target:self
                                        action:@selector(handleButtonShare:)];
}

- (void)userRetrieved:(OAUser *)user new:(BOOL)newUser
{
    self.viewUser.hidden = NO;

    self.labelHello.text = newUser ?
    @"Hello" : [NSString stringWithFormat:@"Welcome back (%d)", (int)user.identities.count];
    
    if (user.displayName.length > 0)
    {
        self.labelName.text = user.displayName;
    }
    else if (user.identities.count > 0)
    {
        self.labelName.text = [user.identities[0] formattedName];
    }
    else
    {
        self.labelName.text = @"";
    }
    
    self.imageViewAvatar.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:user.pictureUrl]];
    self.lastUser = user;
}

- (UIView *)showDimView
{
    UIView *dv = [[UIView alloc] initWithFrame:self.view.bounds];
    dv.backgroundColor = [UIColor colorWithWhite:0 alpha:.5f];

    UIActivityIndicatorView *av =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    [dv addSubview:av];

    av.center = dv.center;
    [av startAnimating];

    [self.view addSubview:dv];

    return dv;
}

- (void)initiateLoginWithProvider:(NSString *)provider
{
    self.viewUser.hidden = YES;

    UIView *dimView = [self showDimView];

    OALoginCallbackSuccess successHandler = ^(OAUser *user, BOOL newUser) {
        [dimView removeFromSuperview];
        [self userRetrieved:user new:newUser];
    };
    
    OALoginCallbackFailure failureHandler = ^(NSError *error) {
        [dimView removeFromSuperview];
        [self showErrorAlert:error];
    };
    
    if (!self.switchSocialLinkEnable.isOn)
    {
        /* regular login */
        [[OAManager sharedInstance] loginWithProvider:provider
                                              success:successHandler
                                              failure:failureHandler];
    }
    else if (self.switchSocialLinkAction.isOn)
    {
        /* link user to new social provider */
        [[OAManager sharedInstance] linkUser:self.lastUser.userToken
                                    provider:provider
                                     success:successHandler
                                     failure:failureHandler];
    }
    else
    {
        /* unlink user from speicified provider */
        [[OAManager sharedInstance] unlinkUser:self.lastUser.userToken
                                      provider:provider
                                       success:successHandler
                                       failure:failureHandler];
    }
    
}

- (void)openProviderSelector
{
    self.viewUser.hidden = YES;
    UIView *dimView = [self showDimView];
    
    void (^callbackSuccess)(OAUser *, BOOL) = ^(OAUser *user, BOOL newUser) {
        [dimView removeFromSuperview];
        [self userRetrieved:user new:newUser];
    };
    
    void (^callbackFailure)(NSError *) = ^(NSError *error) {
        [dimView removeFromSuperview];
        [self showErrorAlert:error];
    };
    
    
    if (!self.switchSocialLinkEnable.isOn)
    {
        /* regular login */
        [[OAManager sharedInstance] loginWithSuccess:callbackSuccess andFailure:callbackFailure];
    }
    else if (self.switchSocialLinkAction.isOn)
    {
        /* link user to new social provider */
        [[OAManager sharedInstance] linkUser:self.lastUser.userToken success:callbackSuccess failure:callbackFailure];
    }
    else
    {
        /* unlink user from speicified provider */
        [[OAManager sharedInstance] unlinkUser:self.lastUser.userToken success:callbackSuccess failure:callbackFailure];
    }
}

- (void)showErrorAlert:(NSError *)error
{
    if (error.code == OA_ERROR_CANCELLED)
    {
        return;
    }
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops", @"")
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitles:nil] show];
}

- (void)handleButtonShare:(id)sender
{
    OAShareViewController *shareVc = [[OAShareViewController alloc] initWithUser:self.lastUser];
    [self.navigationController pushViewController:shareVc animated:YES];
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 4;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:kCellIdentifier];
    });
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier forIndexPath:indexPath];
    if (!cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    switch (indexPath.row)
    {
        case 0:
            cell.imageView.image = [UIImage imageNamed:@"button-login-facebook"];
            cell.textLabel.text = NSLocalizedString(@"Facebook", @"");
            break;
        case 1:
            cell.imageView.image = [UIImage imageNamed:@"button-login-google"];
            cell.textLabel.text = NSLocalizedString(@"Google", @"");
            break;
        case 2:
            cell.imageView.image = [UIImage imageNamed:@"button-login-foursquare"];
            cell.textLabel.text = NSLocalizedString(@"Foursquare", @"");
            break;
        case 3:
            cell.imageView.image = nil;
            cell.textLabel.text = NSLocalizedString(@"More...", @"");
            cell.textLabel.font = [UIFont boldSystemFontOfSize:cell.textLabel.font.pointSize];
            break;
        default:
            break;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:true];
    switch (indexPath.row)
    {
        case 0:
            [self initiateLoginWithProvider:kProviderFacebook];
            break;
        case 1:
            [self initiateLoginWithProvider:kProviderGoogle];
            break;
        case 2:
            [self initiateLoginWithProvider:kProviderFoursquare];
            break;
        case 3:
            [self openProviderSelector];
            break;
        default:
            break;
    }
}

#pragma mark - UI Helper elements

- (IBAction)handleSwitchSocialLinkEnable:(UISwitch *)sw
{
    if (sw.isOn)
    {
        self.viewSocialLinkAction.hidden = false;
        self.viewSocialLinkAction.alpha = 0;
        [UIView animateWithDuration:0.3
                         animations:^{ self.viewSocialLinkAction.alpha = 1.f; }];
    }
    else
    {
        self.viewSocialLinkAction.alpha = 1.f;
        [UIView animateWithDuration:0.3
                         animations:^{ self.viewSocialLinkAction.alpha = 0; }
                         completion:^(BOOL finished) { self.viewSocialLinkAction.hidden = true; }];
    }
}

- (IBAction)handleSocialSwitchLinkAction:(UISwitch *)sw
{
    self.labelSocialLinkAction.text = sw.isOn ? NSLocalizedString(@"Link", @"") : NSLocalizedString(@"Unlink", @"");
}

@end
