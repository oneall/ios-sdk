//
//  OAServerApiConnectionGet.m
//  oneall
//
//  Created by Uri Kogan on 7/2/14.
//  Copyright (c) 2014 urk. All rights reserved.
//
#import "OAServerApiConnectionGet.h"
#import "OAError.h"
#import "OALog.h"

/** API endpoint to use for data retrieval when logging in using OA web form */
static NSString *const kApiEndpoint = @"connection";

@interface OAServerApiConnectionGet () <NSURLConnectionDataDelegate>

/** callback for operation completion */
@property (strong, nonatomic) OAServerApiConnectionCallback callback;

@end

@implementation OAServerApiConnectionGet

#pragma mark - Interface methods

- (BOOL)getInfoWithConnectionToken:(NSString *)token
                          andNonce:(NSString *)nonce
                       andComplete:(OAServerApiConnectionCallback)callback
{
    self.callback = callback;

    NSString *ep = [NSString stringWithFormat:@"%@/%@.json", kApiEndpoint, token];

    OALog(@"Getting user information for token: \"%@\" with nonce \"%@\"", token, nonce);

    NSDictionary *headers = @{kHttpHeaderAuthorization : [NSString stringWithFormat:@"OneAllNonce %@", nonce]};

    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_GET
                            andUrlParameters:nil
                                   anonymous:true
                                  andHeaders:headers
                              andJsonPayload:nil
                            andBinaryPayload:nil];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    OALogError(@"Failed to get user information: %@", error);
    [super connection:connection didFailWithError:error];
    if (self.callback)
    {
        self.callback(nil, error);
        self.callback = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *user;

    [super connectionDidFinishLoading:connection];

    id status = self.response[@"result"][@"status"];

    BOOL success = [status[@"flag"] isEqualToString:@"success"];
    NSInteger code = [status[@"code"] integerValue];
    NSString *info = status[@"info"];

    if (!success || code != HTTP_STATUS_CODE_OK)
    {
        NSString *emsg = [NSString stringWithFormat:@"%@ (%d)", info, (int)code];
        error = [OAError errorWithMessage:emsg andCode:OA_ERROR_AUTH_FAIL];
        OALogError(@"Failed to get user information (%@): %@", error, info);
    }
    else
    {
        user = self.response[@"result"][@"data"][@"user"];
        OALog(@"Successfully read user info: %@", user);
    }

    if (self.callback)
    {
        self.callback(user, error);
        self.callback = nil;
    }
}

@end
