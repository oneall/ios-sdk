//
//  OAShareViewController.m
//  oneall_sample
//
//  Created by Uri Kogan on 7/20/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAShareViewController.h"

@interface OAShareViewController ()

@property (nonatomic, weak) IBOutlet UITextField *labelLink;
@property (nonatomic, weak) IBOutlet UITextField *labelLinkCaption;
@property (nonatomic, weak) IBOutlet UITextField *labelLinkDescription;
@property (nonatomic, weak) IBOutlet UITextField *labelImageLink;
@property (nonatomic, weak) IBOutlet UITextField *labelVideoLink;
@property (nonatomic, weak) IBOutlet UITextField *labelText;
@property (nonatomic, weak) IBOutlet UITextField *labelLinkName;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollViewContents;
@property (weak, nonatomic) UIActivityIndicatorView *activityIndicator;

@property (strong, nonatomic) OAUser *user;
@property (weak, nonatomic) UIView *activityView;

@end

@implementation OAShareViewController

- (id)initWithUser:(OAUser *)user
{
    self = [self init];
    if (self)
    {
        _user = user;
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleKeyboardHidden:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)handleKeyboardShown:(NSNotification *)notification
{
    CGSize kbSize = [notification.userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollViewContents.contentInset = contentInsets;
    self.scrollViewContents.scrollIndicatorInsets = contentInsets;
}

- (void)handleKeyboardHidden:(NSNotification *)notification
{
    self.scrollViewContents.contentInset = UIEdgeInsetsZero;
    self.scrollViewContents.scrollIndicatorInsets = UIEdgeInsetsZero;
}

- (void)hideActivityView
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(hideActivityView) withObject:nil waitUntilDone:NO];
        return;
    }
    [self.activityView removeFromSuperview];
    [self.activityIndicator stopAnimating];
}

- (NSArray *)providersForUser:(OAUser *)user
{
    NSMutableArray *rv = [NSMutableArray arrayWithCapacity:user.identities.count];
    [user.identities enumerateObjectsUsingBlock:^(OAIdentity *obj, NSUInteger idx, BOOL *stop) {
        [rv addObject:obj.provider];
    }];
    return rv;
}

- (void)showActivityView
{
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showActivityView) withObject:nil waitUntilDone:NO];
        return;
    }

    [self hideActivityView];

    UIView *dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];

    UIActivityIndicatorView *av =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];

    [dimView addSubview:av];
    av.center = dimView.center;
    av.hidesWhenStopped = true;

    [av startAnimating];

    [self.view addSubview:av];

    self.activityView = dimView;
    self.activityIndicator = av;
}

- (IBAction)handleButtonShare:(id)sender
{
    NSString *text = self.labelText.text.length ? self.labelText.text : nil;
    NSURL *pictureUrl = self.labelImageLink.text.length ? [NSURL URLWithString:self.labelImageLink.text] : nil;
    NSURL *videoUrl = self.labelVideoLink.text.length ? [NSURL URLWithString:self.labelImageLink.text] : nil;
    NSURL *linkUrl = self.labelLink.text.length ? [NSURL URLWithString:self.labelLink.text] : nil;
    NSString *linkName = self.labelLinkName.text.length ? self.labelLinkName.text : nil;
    NSString *linkCaption = self.labelLinkCaption.text.length ? self.labelLinkCaption.text : nil;
    NSString *linkDescription = self.labelLinkDescription.text.length ? self.labelLinkDescription.text : nil;

    [self showActivityView];

    BOOL res =
    [[OAManager sharedInstance] postMessageWithText:text
                                         pictureUrl:pictureUrl
                                           videoUrl:videoUrl
                                            linkUrl:linkUrl
                                           linkName:linkName
                                        linkCaption:linkCaption
                                    linkDescription:linkDescription
                                     enableTracking:NO
                                          userToken:self.user.userToken
                                       publishToken:self.user.publishToken.key
                                        toProviders:[self providersForUser:self.user]
                                           callback:^(BOOL failed, OAMessagePostResult *result, OAError *error) {
                                               [self hideActivityView];
                                               if (failed)
                                               {
                                                   [self shareFailure:error];
                                               }
                                               else
                                               {
                                                   [self shareSuccess];
                                               }
                                           }];
    if (!res)
    {
        [self hideActivityView];
        [self shareFailure:
                [OAError errorWithMessage:NSLocalizedString(@"User not loogged in or no providers specified", @"")
                                  andCode:OA_ERROR_MESSAGE_POST_FAIL]];
    }
}

- (void)shareFailure:(NSError *)error
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ooops", @"")
                                message:error.localizedDescription
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                      otherButtonTitles:nil] show];
}

- (void)shareSuccess
{
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Succeeded", @"")
                                message:NSLocalizedString(@"Message shared successfully", @"")
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", @"")
                      otherButtonTitles:nil] show];
}

@end
