OneAll-iOS SDK
===

SDK allowing to authenticate and make posts on user's walls.

#  Features
- Login using OneAll authentication using UIWebView
- Login using OneAll by using native SDK for Facebook or Twitter (iOS6 and later)

# Installation

## Setting up XCode Project

### Add the OneAll SDK to the Project
Using Finder drag the OneAll.xcodeproj file into the XCode and place in your project:

![XCode Setup](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_drag_xcode.png)

### Setup Header Paths
Now select your project in project explorer and click “Build Settings”:

![Build Settings](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_build_settings.png)

Make sure your target is selected on the left of the panel, then find “Header Search Paths” in the list of settings and add the folder in which the OneAll library is located. This would normally be the folder from which you dragged the `OneAll.xcodeproj` from:

![Header Search Paths](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_header_search_path.png)

### Link the Library
 Now, go into “Build Phases”, expand “Link Binary With Libraries” section and click “+” in this section. Add the `libOneAll.a` from the top of the list: 

![Link Library](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_build_phases.png)

### Add Resources
While at the same screen, make sure the resources of the library are added to the final executable by dragging it from the project explorer into “Copy Bundle Resources” section:

![Resources](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_add_resources.png)

### Setup Source Files
Import the SDK main include file at the top of AppDelegate.m:

``` objective-c
#import <OneAll/OneAll.h>
```

In your AppDelegate.m file, in `application:didFinishLaunchingWithOptions:` add the following initialization code:
``` objective-c
- (BOOL)application:(UIApplication *)application
     didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
 {
     [[OAManager sharedInstance] setupWithSubdomain:@"foo"];
 }
```
Of course, replace "foo" with your own OneAll application subdomain.

Add a button on one of the forms and create an action for it in corresponding controller. In this handler add the following code:
``` objective-c
[[OAManager sharedInstance] loginWithSuccess:^(OAUser *user) {
    NSLog(@"User logged in: %@", user);
}
                                  andFailure:^(NSError *error) {
    NSLog(@"Failed to login user: %@, %@", error.localizedDescription, error.userInfo);
}];
```

You are all set! Running the project and tapping the new button you should see the login screen with all possible providers selection.

# Usage
## Login Using Own Provider Selector
Instead of using SDK’s own login screen you may design your own selector of provider types. In order to login using specific provider, use the following call (with Reddit authentication):
``` objective-c
[[OAManager sharedInstance] loginWithProvider:OA_PROVIDER_REDDIT
                                      success:^{ NSLog(@”Login succeeded”); }
                                      failure:^{ NSLog(@”Login failed”); }];
```
This will allow you to fully customise the appearance of the login window and just call the library to do an actual authentication.

## Controlling Network Activity Indicator
Generally, network activity indicator should be controlled by the application. If the application does not use, it may transfer the control of the indicator to the library by calling
``` objective-c
[[OAManager sharedInstance] setNetworkActivityIndicatorControlledByOa:true];
```
The indicator will be activated whenever the SDK is communicating with servers.

![Resources](https://raw.githubusercontent.com/oneall/ios-sdk/master/screenshots/install_network_notification.png)

## Setting up Native Twitter Auth
To use native Twitter Authentication, you have to setup the library with more settings. Replace the initialisation with the following call:
``` objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[OAManager sharedInstance] setupWithSubdomain:@"foo"
                                     facebookAppId:nil
                                twitterConsumerKey:@”twitter_consumer_key”
                                     twitterSecret:@”twitter_secret”];
}
```
Of course, replace `twitter_consumer_key` and `twitter_secret` with values from your Twitter application settings (https://apps.twitter.com). Now when trying to login, the SDK will attempt to login using native iOS Twitter authentication and if unavailable, fall back to regular web based login.

## Setting up Native Facebook Auth
First setup, your Facebook application according to Facebook’s Getting Started tutorial: https://developers.facebook.com/docs/ios/getting-started. Pay attention that you add your Facebook.framework
To use native Twitter Authentication, you have to pass Facebook application ID to the initialisation code:
``` objective-c
- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[OAManager sharedInstance] setupWithSubdomain:@"foo"
                                     facebookAppId:@”20531316728”
                                twitterConsumerKey:nil
                                     twitterSecret:nil];
}
```
Of course, replace the facebook id parameter with AppID of your Facebook app (https://developers.facebook.com/apps).
Make sure URL’s are handled by the SDK too. Override application:openURL:sourceApplication: and inform the manager about URL opening:
``` objective-c
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [[OAManager sharedInstance] handleOpenUrl:url sourceApplication:sourceApplication];
}
```
In addition, take care of application returning from background by overriding `applicationDidBecomeActive`.
``` objective-c
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[OAManager sharedInstance] didBecomeActive];
}
```
Now when trying to login, the SDK will attempt to login using Facebook SDK using installed Facebook application and if unavailable, fall back to regular web based login.

## Posting Message to User’s Wall
The SDK allows to post messages to user wall according to this guide: http://docs.oneall.com/api/resources/users/write-to-users-wall/ in order to make the post, `OAManager` exposes the following:
``` objective-c
[[OAManager sharedInstance] postMessageWithText:@”Lorem Ipsum”
                 pictureUrl:[NSURL URLWithString:@”https://www.google.co.il/images/srpr/logo11w.png”
                   videoUrl:nil
                    linkUrl:[NSURL URLWithString:@”http://www.google.com”]
                   linkName:@”Google”
                linkCaption:nil
            linkDescription:nil
             enableTracking:true
                  userToken:user.userToken
               publishToken:user.publishToken.key
                toProviders:@[@(OA_PROVIDER_FACEBOOK)]
                   callback:^(BOOL failed, OAMessagePostResult *result, OAError *error) {
                       NSLog(@”Message posted with status: %d”, (int)failed);
                   }];
```

# License
The sample project (but not the SDK) includes Facebook SDK which is distributed under Apache MIT licese

[@urk](http://twitter.com/UrK)
[OneAll](http://www.oneall.com)