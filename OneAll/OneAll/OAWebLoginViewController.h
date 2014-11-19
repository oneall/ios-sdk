//
//  OAWebLoginViewController.h
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <UIKit/UIKit.h>

/** protocol used to message implementing delegate about login progress */
@protocol OAWebLoginDelegate <NSObject>

/**
 * login cancelled
 *
 * @param sender sender of the event `OAWebLoginViewController` object
 */
- (void)webLoginCancelled:(id)sender;

/**
* login completed with callback URL. This is the result of logging in using web form on OA servers. After completion
* of login, the caller has to retrieve information about the connection and the user using access token received via
* URL query parameters.
*
* @param sender sender of the event `OAWebLoginViewController` object
*/
- (void)webLoginComplete:(id)sender withUrl:(NSURL *)url;

/**
* login completed failed
*
* @param sender sender of the event `OAWebLoginViewController` object
*
* @param error connection error
*/
- (void)webLoginFailed:(id)sender error:(NSError *)error;

@end

@interface OAWebLoginViewController : UIViewController

/**
 * show web view with OA form to log user in
 *
 * @param delegate delegate used to listen to completion events
 *
 * @param url initial URL used to login. Provder dependent and built externally by the caller.
 */
+ (UIViewController *)webLoginWithDelegate:(id<OAWebLoginDelegate>)delegate andUrl:(NSURL *)url;

@end
