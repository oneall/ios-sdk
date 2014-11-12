//
//  OABundle.h
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

/** Class allowing to use resources from bundle other than default */
@interface OABundle : NSObject

/** getter of local OneAll resources bundle */
+ (NSBundle *)libraryResourcesBundle;

/** read image from either main bundle (if exists) or from local OneAll bundle */
+ (UIImage *)imageNamed:(NSString *)name;

@end
