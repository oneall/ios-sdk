//
//  OAWebLoginViewController.m
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAWebLoginViewController.h"
#import "OABundle.h"
#import "OAGlobals.h"
#import "OALog.h"
#import "OANetworkActivityIndicatorControl.h"

@interface OAWebLoginViewController () <UIWebViewDelegate>

@property (weak, nonatomic) id<OAWebLoginDelegate> actionDelegate;
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@property (strong, nonatomic) UIView *dimView;
@property (strong, nonatomic) NSURL *url;

@end

@implementation OAWebLoginViewController

+ (UIViewController *)webLoginWithDelegate:(id<OAWebLoginDelegate>)delegate andUrl:(NSURL *)url
{
    OAWebLoginViewController *vc = [[OAWebLoginViewController alloc] initWithDelegate:delegate andUrl:url];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    vc.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                                            style:UIBarButtonItemStyleDone
                                                                           target:vc
                                                                           action:@selector(handleButtonClose:)];
    return nav;
}

/* overrides original intWithNibName:bundle. The bundle is not the original one but the bundle added to the project.
 * Since this is an external library the XIB does not appear in mainBundle
 */
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [super initWithNibName:NSStringFromClass([self class]) bundle:[OABundle libraryResourcesBundle]];
}

- (id)initWithDelegate:(id<OAWebLoginDelegate>)delegate andUrl:(NSURL *)url
{
    self = [self init];
    if (self)
    {
        _actionDelegate = delegate;
        _url = url;
    }
    return self;
}

/* setup the delegate for web view and start request loading as soon as the view loads */
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.webView.delegate = self;
    [self loadWebRequest];
}

- (IBAction)handleButtonClose:(id)sender
{
    [self.actionDelegate webLoginCancelled:self];
}

- (void)loadWebRequest
{
    OALog(@"Loading web request %@", self.url);
    NSURLRequest *req = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:req];
    [[OANetworkActivityIndicatorControl sharedInstance] turnOn];
}

#pragma mark - UIWebViewDelegate

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    OALog(@"Page loading complete: %@", webView.request.URL);
    [self hideActivityOverlay];
    [[OANetworkActivityIndicatorControl sharedInstance] turnOff];
}

/* the web view is active until the last redirect to custom "oneall:" scheme. When the controller detects that OA server
 * redirected to custom "oneall:" URL scheme, it captures the request and returns the URL to the caller. The URL is not
 * being loaded */
- (BOOL)webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    OALog(@"Loading URL %@", request.URL);

    if ([[[request URL] scheme]isEqualToString:kCustomUrlScheme])
    {
        OALog(@"Skipping loading");
        [self.actionDelegate webLoginComplete:self withUrl:request.URL];
        return NO;
    }
    else
    {
        [self showActivityOverlay];
        return YES;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    OALog(@"Loading URL %@ failed: %@, %@", webView.request.URL, error.localizedDescription, error.userInfo);
    [self.actionDelegate webLoginCancelled:self];
    [[OANetworkActivityIndicatorControl sharedInstance] turnOff];
}

#pragma mark - Activity overlay handling

/* shown activity overlay is built in the code and not in XIB to avoid complications with non main bundle for external
 * library */
- (void)showActivityOverlay
{
    /* switch to main thread if needed */
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(showActivityOverlay) withObject:nil waitUntilDone:NO];
        return;
    }

    /* remove the old activity */
    [self hideActivityOverlay];

    self.dimView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.dimView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5f];

    [self.view addSubview:self.dimView];

    UIActivityIndicatorView *av = [[UIActivityIndicatorView alloc] init];
    av.color = [UIColor whiteColor];
    [av startAnimating];
    [self.dimView addSubview:av];

    av.frame = CGRectMake(
        (CGRectGetWidth(self.dimView.frame) - CGRectGetWidth(av.frame)) / 2,
        (CGRectGetHeight(self.dimView.frame) - CGRectGetHeight(av.frame)) / 2,
        CGRectGetWidth(av.frame),
        CGRectGetHeight(av.frame));
}

- (void)hideActivityOverlay
{
    /* switch to main thread if needed */
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(hideActivityOverlay) withObject:nil waitUntilDone:NO];
        return;
    }
    [self.dimView removeFromSuperview];
}

@end
