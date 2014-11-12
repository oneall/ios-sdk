//
//  OAShareViewController.h
//  oneall_sample
//
//  Created by Uri Kogan on 7/20/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <OneAll/OneAll.h>

/**
 * Share view controller which allows the user to enter all the data of the shared message and post the message to all
 * providers of the user.
 */
@interface OAShareViewController : UIViewController

/** initialize the controller with user object.
 * example usage of the controller:
 *
 * @code
 * OAShareViewController *oav = [[OAShareViewController alloc] initWithUser:user];
 * [self presentViewController:oav animated:true completion:nil]
 * @endcode
 *
 * @param user user object used to retrieve information about all providers set up for current user and user's sharing
 * token.
 */
- (id)initWithUser:(OAUser *)user;

@end
