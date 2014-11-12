//
//  OABundle.m
//  oneall
//
//  Created by Uri Kogan on 6/30/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OABundle.h"

/** name of the bundle of OneAll library */
static NSString *const kBundleName = @"OneAllResources";

/** extension of bundle file */
static NSString *const kBundleExt = @"bundle";

@implementation OABundle

+ (NSBundle *)libraryResourcesBundle
{
    static dispatch_once_t onceToken;
    static NSBundle *myLibraryResourcesBundle = nil;
    dispatch_once(&onceToken, ^{
        myLibraryResourcesBundle =
        [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:kBundleName withExtension:kBundleExt]];
    });
    return myLibraryResourcesBundle;
}

+ (UIImage *)imageNamed:(NSString *)name
{
    UIImage *imageFromMainBundle = [UIImage imageNamed:name];
    if (imageFromMainBundle)
    {
        return imageFromMainBundle;
    }

    UIImage *imageFromMyLibraryBundle =
    [UIImage imageWithContentsOfFile:[[self libraryResourcesBundle] pathForResource:name ofType:@"png"]];

    return imageFromMyLibraryBundle;
}

@end
