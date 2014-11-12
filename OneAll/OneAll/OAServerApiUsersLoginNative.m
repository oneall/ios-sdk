//
// Created by Uri Kogan on 10/7/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAServerApiUsersLoginNative.h"
#import "OAError.h"
#import "OALog.h"

/** API endpoint to use for connection data retrieval with native authentication (Twitter/Facebook) */
static NSString *const kNativeAuthApiEndpoint = @"users";

@interface OAServerApiUsersLoginNative () <NSURLConnectionDataDelegate>
@property (strong, nonatomic) OAServerApiUsersLoginNativeCallback callback;
@end

@implementation OAServerApiUsersLoginNative

#pragma mark - Interface methods

- (BOOL)getInfoWithFacebookToken:(NSString *)token andComplete:(OAServerApiUsersLoginNativeCallback)callback
{
    self.callback = callback;

    NSString *ep =
        [NSString stringWithFormat:@"%@.json", kNativeAuthApiEndpoint];

    NSDictionary *dict = @{
        @"request": @{
            @"user": @{
                @"action": @"import_from_access_token",
                @"identity": @{
                    @"source": @{
                        @"key": @"facebook",
                        @"access_token": @{
                            @"key": token
                        }
                    }
                }
            }
        }
    };

    OALog(@"Trying to login with Facebook with token %@", token);
    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_PUT
                            andUrlParameters:nil
                                   anonymous:false
                                  andHeaders:nil
                              andJsonPayload:dict
                            andBinaryPayload:nil];
}

- (BOOL)getInfoWithTwitterToken:(NSString *)token
                         secret:(NSString *)secret
                       complete:(OAServerApiUsersLoginNativeCallback)callback
{
    self.callback = callback;

    NSString *ep =
        [NSString stringWithFormat:@"%@.json", kNativeAuthApiEndpoint];

    NSDictionary *dict = @{
        @"request": @{
            @"user": @{
                @"action": @"import_from_access_token",
                @"identity": @{
                    @"source": @{
                        @"key": @"twitter",
                        @"access_token": @{
                            @"key": token,
                            @"secret": secret
                        }
                    }
                }
            }
        }
    };

    OALog(@"Trying to login with Twitter with token %@", token);
    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_PUT
                            andUrlParameters:nil
                                   anonymous:false
                                  andHeaders:nil
                              andJsonPayload:dict
                            andBinaryPayload:nil];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    OALogError(@"Native auth login failed: %@", error);
    [super connection:connection didFailWithError:error];
    if (self.callback)
    {
        self.callback(nil, false, error);
        self.callback = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;
    NSDictionary *user;

    [super connectionDidFinishLoading:connection];

    id status = self.response[@"request"][@"status"];

    BOOL success = [status[@"flag"] isEqualToString:@"success"];
    NSInteger code = [status[@"code"] integerValue];
    NSString *info = status[@"info"];

    BOOL codeSuccess = (code == HTTP_STATUS_CODE_OK || code == HTTP_STATUS_CODE_CREATED);

    if (!success || !codeSuccess)
    {
        OALogError(@"Native login failed. Success=%@. Code=%d. Response=%@", success ? @"true" : @"false", (int)code,
            self.response);
        NSString *emsg = [NSString stringWithFormat:@"%@ (%d)", info, (int)code];
        error = [OAError errorWithMessage:emsg andCode:OA_ERROR_AUTH_FAIL];
    }
    else
    {
        user = self.response[@"result"][@"data"][@"user"];
        OALog(@"Native login returned valid user: %@", user);
    }

    if (self.callback)
    {
        self.callback(user, (code == HTTP_STATUS_CODE_CREATED), error);
        self.callback = nil;
    }
}

@end
