//
//  OAServerApiConnectionGet.h
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "OAServerApiBase.h"

/** callback for connection information retrieval. Sends retrieved data dictionary and optional error. */
typedef void (^OAServerApiConnectionCallback)(NSDictionary *, NSError *);

/** command retrieving connection information from the OA server */
@interface OAServerApiConnectionGet : OAServerApiBase

/**
 * get information about current connection after login using OA REST API
 *
 * @param token token received during initial login
 *
 * @param nonce same nonce string that was sent to the server during login
 *
 * @param callback method called on information retrieval completion, both on success and failure; may be nil
 *
 * @see http://docs.oneall.com/api/resources/connections/read-connection-details/
 */
- (BOOL)getInfoWithConnectionToken:(NSString *)token
                          andNonce:(NSString *)nonce
                       andComplete:(OAServerApiConnectionCallback)callback;

@end
