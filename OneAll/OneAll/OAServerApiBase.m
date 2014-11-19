//
// Created by Uri Kogan on 5/17/14.
// Copyright (c) 2014 Uri Kogan. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "OAServerApiBase.h"
#import "NSString+ULREncode.h"
#import "OASettings.h"
#import "OALog.h"
#import "OANetworkActivityIndicatorControl.h"
#import "OAGlobals.h"

static NSString *const kConfigUser = @"apiBaseUser";
static NSString *const kConfigApiKey = @"apiBaseKey";

NSString *const kHttpHeaderAuthorization = @"Authorization";

NSString *const kHttpHeaderContentType = @"Content-Type";
NSString *const kHttpHeaderContentTypeJson = @"application/json";
NSString *const kHttpHeaderContentTypeImage = @"image/jpeg";

@interface OAServerApiBase ()
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, nonatomic) NSString *apiKey;
@end

@implementation OAServerApiBase
{
    NSMutableData *_data;
    NSDate *_startTime;
    dispatch_once_t _instanceSpent;
}

#pragma mark - Lifecycle

/* initialize the object and read default user and token from locally stored settings */
- (id)init
{
    self = [super init];
    if (self)
    {
        _data = [NSMutableData data];
        _username = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigUser];
        _apiKey = [[NSUserDefaults standardUserDefaults] objectForKey:kConfigApiKey];
    }
    return self;
}

#pragma mark - Interface methods

- (BOOL)createConnectionForEndpoint:(NSString *)endpoint
                         withMethod:(NSString *)httpMethod
                   andUrlParameters:(NSDictionary *)urlParams
                          anonymous:(BOOL)anonymous
                         andHeaders:(NSDictionary *)headers
                     andJsonPayload:(NSDictionary *)jsonPayload
                   andBinaryPayload:(NSData *)binaryPayload
{
    NSURLRequest *request = [self createRequestForEndpoint:endpoint
                                                    method:httpMethod
                                             urlParameters:urlParams
                                                 anonymous:anonymous
                                         additionalHeaders:headers
                                               jsonPayload:jsonPayload
                                             binaryPayload:binaryPayload];
    if (!request)
    {
        return false;
    }

    OALog(@"Creating connection to %@ (method=%@)", [request URL], httpMethod);

    self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:NO];
    [self.connection scheduleInRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    [self.connection start];

    [[OANetworkActivityIndicatorControl sharedInstance] turnOn];

    return true;
}

+ (NSString *)apiServer
{
    return [NSString stringWithFormat:@"https://%@.api.oneall.com", [[OASettings sharedInstance] subdomain]];
}

+ (void)setUser:(NSString *)username withToken:(NSString *)token
{
    if (username)
    {
        [[NSUserDefaults standardUserDefaults] setValue:username forKey:kConfigUser];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigUser];
    }

    if (token)
    {
        [[NSUserDefaults standardUserDefaults] setValue:token forKey:kConfigApiKey];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kConfigApiKey];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString *)createUrlForEndpoint:(NSString *)endpoint
{
    return [NSString stringWithFormat:@"%@/%@", [OAServerApiBase apiServer], endpoint];
}

+ (BOOL)parseBool:(id)val
{
    if (val == nil)
    {
        return false;
    }
    if ([val isKindOfClass:[NSNumber class]])
    {
        return [val boolValue];
    }
    return false;
}

#pragma mark - NSURLConnectionDelegate

/* log the failed request */
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[OANetworkActivityIndicatorControl sharedInstance] turnOff];

    OALog(@"Connection %@ failed after %lf with status %ld: %@",
          connection.originalRequest.URL,
          [[NSDate date] timeIntervalSinceDate:_startTime],
          (long)[self statusCode],
          [error localizedDescription]);
}

#pragma mark - NSURLConnectionDataDelegate

/* append incoming data to local data array */
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_data appendData:data];
}

/* record the HTTP response of the server */
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse *httpResp = (NSHTTPURLResponse *)response;
    _statusCode = (HttpStatusCode) [httpResp statusCode];
}

/* process the server response: do basic parsing and logging */
- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSError *error;

    [[OANetworkActivityIndicatorControl sharedInstance] turnOff];

    OALog(@"Connection %@ completed after %lf with status %ld", connection.originalRequest.URL,
          [[NSDate date] timeIntervalSinceDate:_startTime], (long)self.statusCode);

    NSDictionary *resp = [NSJSONSerialization JSONObjectWithData:_data options:0 error:&error];

    self.response = resp[@"response"];
}

#pragma mark - Utilities

- (NSURLRequest *)createRequestForEndpoint:(NSString *)endpoint
                                    method:(NSString *)httpMethod
                             urlParameters:(NSDictionary *)urlParams
                                 anonymous:(BOOL)anonymous
                         additionalHeaders:(NSDictionary *)headers
                               jsonPayload:(NSDictionary *)jsonPayload
                             binaryPayload:(NSData *)binaryPayload
{
    /* each instance can be used only once
     * first, make sure the request is used only once */
    __block BOOL unused = false;
    dispatch_once(&_instanceSpent, ^{
        unused = true;
    });
    if (!unused)
    {
        OALog(@"One time use instance spent already");
        return nil;
    }

    /* there can be only one kind of payload: either binary or JSON */
    if (jsonPayload && binaryPayload)
    {
        OALog(@"Request may have either JSON or binary payload but not both");
        return nil;
    }

    /* record request start time for the purpose of logging/profiling */
    _startTime = [NSDate date];

    NSString *url = [self createUrlForEndpoint:endpoint];

    /* build the URL from the original URL and URL parameters by URL-encoding and combining them into single query
     * string */
    if ([urlParams count])
    {
        NSMutableArray *prms = [NSMutableArray arrayWithCapacity:[urlParams count]];

        [urlParams enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            NSString *encKey = [key urlEncodeUsingEncoding:NSUTF8StringEncoding];
            NSString *strVal = [obj isKindOfClass:NSString.class] ? obj : [obj stringValue];
            NSString *encObj = [strVal urlEncodeUsingEncoding:NSUTF8StringEncoding];
            NSString *p = [NSString stringWithFormat:@"%@=%@", encKey, encObj];
            [prms addObject:p];
        }];

        NSString *queryString = [prms componentsJoinedByString:@"&"];
        url = [NSString stringWithFormat:@"%@?%@", url, queryString];
    }

    NSMutableURLRequest *req = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]
                                                       cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                   timeoutInterval:kConnectionTimeout];

    [req setHTTPMethod:httpMethod];

    /* set content type of the request according to the type of passed data: image or JSON */
    if (binaryPayload)
    {
        [req addValue:kHttpHeaderContentTypeImage forHTTPHeaderField:kHttpHeaderContentType];
    }
    else
    {
        [req addValue:kHttpHeaderContentTypeJson forHTTPHeaderField:kHttpHeaderContentType];
    }

    /* add authentication header to the request */
    if (!anonymous && self.username && self.apiKey)
    {
        NSString *authString = [NSString stringWithFormat:@"%@:%@", self.username, self.apiKey];
        NSData *authData = [authString dataUsingEncoding:NSUTF8StringEncoding];
        NSString *base64String = [authData base64EncodedStringWithOptions:0];
        NSString *fullAuthString = [NSString stringWithFormat:@"Basic %@", base64String];
        [req addValue:fullAuthString forHTTPHeaderField:kHttpHeaderAuthorization];
    }

    /* add all the extra headers into the request */
    [headers enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [req addValue:obj forHTTPHeaderField:key];
    }];

    /* build JSON body or put binary payload into the request */
    if (jsonPayload)
    {
        NSError *error;
        NSData *body = [NSJSONSerialization dataWithJSONObject:jsonPayload options:0 error:&error];
        if (!body || error)
        {
            OALog(@"Cannot serialize object: %@", [error localizedDescription]);
            return nil;
        }
        [req setHTTPBody:body];
    }
    else if (binaryPayload)
    {
        [req setHTTPBody:binaryPayload];
    }

    return req;
}

@end
