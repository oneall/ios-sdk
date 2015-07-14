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

- (BOOL)getInfoWithFacebookToken:(NSString *)token
                       userToken:(NSString *)userToken
                        complete:(OAServerApiUsersLoginNativeCallback)callback
{
    return [self getNativeInfoForPlatform:@"facebook" key:token secret:nil userToken:userToken complete:callback];
}

- (BOOL)getInfoWithTwitterToken:(NSString *)token
                         secret:(NSString *)secret
                      userToken:(NSString *)userToken
                       complete:(OAServerApiUsersLoginNativeCallback)callback
{
    return [self getNativeInfoForPlatform:@"twitter" key:token secret:secret userToken:userToken complete:callback];
}

- (BOOL)unlinkWithFacebookToken:(NSString *)token
                      userToken:(NSString *)userToken
                       complete:(OAServerApiUsersLoginNativeCallback)callback
{
    return [self unlinkNativeInfoForPlatform:@"facebook" key:token secret:nil userToken:userToken complete:callback];
}

- (BOOL)unlinkWithTwitterToken:(NSString *)token
                        secret:(NSString *)secret
                     userToken:(NSString *)userToken
                      complete:(OAServerApiUsersLoginNativeCallback)callback
{
    return [self unlinkNativeInfoForPlatform:@"twitter" key:token secret:secret userToken:userToken complete:callback];
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

#pragma mark - Utilities

- (NSDictionary *)buildRequestPlatform:(NSString *)platform
                                action:(NSString *)action
                             userToken:(NSString *)userToken
                                   key:(NSString *)key
                                secret:(NSString *)secret {
    
    NSMutableDictionary *dict =
    [@{
      @"request": [@{
              @"user": [@{
                      @"action": action,
                      @"identity": [@{
                              @"source": [@{
                                      @"key": platform,
                                      @"access_token": [@{
                                              @"key": key
                                      } mutableCopy]
                              } mutableCopy]
                      } mutableCopy]
              } mutableCopy]
      } mutableCopy]
    } mutableCopy];
    
    if (secret != nil) {
        dict[@"request"][@"user"][@"identity"][@"source"][@"access_token"][@"secret"] = secret;
    }
    
    if (userToken != nil && userToken != (id)[NSNull null])
    {
        dict[@"request"][@"user"][@"user_token"] = userToken;
    }
    
    return dict;
}

- (BOOL)unlinkNativeInfoForPlatform:(NSString *)platform
                                key:(NSString *)key
                             secret:(NSString *)secret
                          userToken:(NSString *)userToken
                           complete:(OAServerApiUsersLoginNativeCallback)callback {
    self.callback = callback;

    NSString *ep = [NSString stringWithFormat:@"%@.json", kNativeAuthApiEndpoint];
    
    NSDictionary *dict = [self buildRequestPlatform:platform
                                             action:@"delete_by_access_token"
                                          userToken:userToken
                                                key:key
                                             secret:secret];
    OALog(@"Trying to unlink user %@ from platform %@", userToken, platform);
    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_DELETE
                            andUrlParameters:nil
                                   anonymous:false
                                  andHeaders:nil
                              andJsonPayload:dict
                            andBinaryPayload:nil];
}

- (BOOL)getNativeInfoForPlatform:(NSString *)platform
                             key:(NSString *)key
                          secret:(NSString *)secret
                       userToken:(NSString *)userToken
                        complete:(OAServerApiUsersLoginNativeCallback)callback
{
    self.callback = callback;
    
    NSString *ep = [NSString stringWithFormat:@"%@.json", kNativeAuthApiEndpoint];
    
    NSDictionary *dict = [self buildRequestPlatform:platform
                                             action:@"import_from_access_token"
                                          userToken:userToken
                                                key:key
                                             secret:secret];
    
    OALog(@"Trying to login native with with token %@", key);
    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_PUT
                            andUrlParameters:nil
                                   anonymous:false
                                  andHeaders:nil
                              andJsonPayload:dict
                            andBinaryPayload:nil];
}

@end
