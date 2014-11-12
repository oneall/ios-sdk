//
//  NSString+ULREncode.m
//  CarRentalDemo
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 Uri Kogan. All rights reserved.
//
#import "NSString+ULREncode.h"

@implementation NSString(ULREncode)

- (NSString *)urlEncodeUsingEncoding:(NSStringEncoding)encoding
{
    CFStringRef encoded =
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)self,
                                            NULL,
                                            (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                                            CFStringConvertNSStringEncodingToEncoding(encoding));
    NSString *rv = [NSString stringWithFormat:@"%@", (__bridge NSString *)encoded];
    CFRelease(encoded);
    return rv;
}

@end
