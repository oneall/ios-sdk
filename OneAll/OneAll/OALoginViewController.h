//
//  OALoginViewController.h
//  oneall
//
//  Created by Uri Kogan on 7/3/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "OAProviderManager.h"
#import "OACommonTypes.h"

/** protocol used to call back the user on GUI events: closing the window, tapping on one of authentication schemes */
@protocol OALoginControllerDelegate <NSObject>

/** called on user selecting one of authentication methods in view controller
*
* @param sender sender of this event: will be generally set to current view controller object
*
* @param provider selected authentication provider
*/
- (void)oaLoginController:(id)sender selectedMethod:(OAProvider *)provider;

/** called on user cancelling authentication, for example by tapping "Cancel" button
 * @param sender sender of this event: will be generally set to current view controller object
 */
- (void)oaLoginControllerCancelled:(id)sender;

@end

/** login view controller showing table of all possible authentication options */
@interface OALoginViewController : UIViewController

/** action stored as a part of this controller, used by the caller to pass information about social link */
@property (nonatomic) OASocialLinkAction action;

/** user token stored as a part of this controller, used by the caller to pass information about social link */
@property (nonatomic, strong) NSString *userToken;

/** view controller initialization
*
* @param delegate delegate that will be used to inform the user about GUI events
*/
- (id)initWithDelegate:(id<OALoginControllerDelegate>)delegate;

/** create and show the view with attached view controller specifying the delegate.
*
* The view will be shown on main application window covering the whole screen
*
* @param delegate delegate that will be used to inform the caller about GUI events
*/
+ (OALoginViewController *)showWithDelegate:(id<OALoginControllerDelegate>)delegate;

/** create and show the view with attached view controller specifying the delegate.
*
* The resulting view will be shown using presentViewController on a specified parent controller
*
* @param parentVc parent view controller to show the login view on
*
* @param delegate delegate that will be used to inform the caller about GUI events
*/
+ (OALoginViewController *)showInContainer:(UIViewController *)parentVc
                              withDelegate:(id<OALoginControllerDelegate>)delegate;

@end
