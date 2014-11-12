//
//  OALog.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>

#if defined(OA_LOG_DISABLE)
#define OALog(fmt, ...) {}
#else
#define OALog NSLog
#endif
#define OALogError OALog
