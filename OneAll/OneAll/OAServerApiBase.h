//
// Created by Uri Kogan on 7/2/14.
// Copyright (c) 2014 Uri Kogan. All rights reserved.
//
#import <Foundation/Foundation.h>

#define HTTP_METHOD_GET @"GET"
#define HTTP_METHOD_POST @"POST"
#define HTTP_METHOD_PUT @"PUT"
#define HTTP_METHOD_PATCH @"PATCH"
#define HTTP_METHOD_DELETE @"DELETE"

/** standard HTTP status codes */
typedef NS_ENUM(NSInteger, HttpStatusCode)
{
    HTTP_STATUS_CODE_OK = 200,
    HTTP_STATUS_CODE_CREATED = 201,
    HTTP_STATUS_CODE_ACCEPTED = 202,
    HTTP_STATUS_CODE_NO_CONTENT = 204,
    HTTP_STATUS_CODE_MULTI_STATUS = 207,
    HTTP_STATUS_CODE_UNAUTHORIZED = 401
};

/** Authorization HTTP header */
extern NSString *const kHttpHeaderAuthorization;

@interface OAServerApiBase : NSObject<NSURLConnectionDataDelegate, NSURLConnectionDelegate>

/** HTTP status code of request. Set only on when response is received */
@property (nonatomic) HttpStatusCode statusCode;

/** parsed response, generally `NSDictionary *` instance */
@property (nonatomic, strong) id response;

/** username used for the request */
@property (strong, nonatomic) NSString *username;

/** parse boolean from object */
+ (BOOL)parseBool:(id)val;

/** create basic connection */
- (BOOL)createConnectionForEndpoint:(NSString *)endpoint
                         withMethod:(NSString *)httpMethod
                   andUrlParameters:(NSDictionary *)urlParams
                          anonymous:(BOOL)anonymous
                         andHeaders:(NSDictionary *)headers
                     andJsonPayload:(NSDictionary *)jsonPayload
                   andBinaryPayload:(NSData *)binaryPayload;

/** getter of API server address */
+ (NSString *)apiServer;

/** update user and session token to be used in the request */
+ (void)setUser:(NSString *)username withToken:(NSString *)token;

@end
