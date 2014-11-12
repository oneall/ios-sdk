//
//  NSString+ULREncode.h
//  CarRentalDemo
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 Uri Kogan. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString(ULREncode)

/** Encode string into URL format safe for use as a part of URL query parameter
*
* @param encoding endcoding to use, you'll generally want to use NSUTF8StringEncoding
*
* @return URL-encoded strings
*/
-(NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding;
@end
