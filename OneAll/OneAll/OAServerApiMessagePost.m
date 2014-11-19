//
// Created by Uri Kogan on 7/16/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAServerApiMessagePost.h"
#import "OALog.h"

static NSString *const kApiEndpoint = @"users/%@/publish.json";

static NSString *const kOAPublishAuthType = @"OneAllPublishToken";

@interface OAServerApiMessagePost ()
@property (strong, nonatomic) OAMessagePostCallback callback;
@end

@implementation OAServerApiMessagePost

#pragma mark - Interface methods

- (BOOL)postMessageWithText:(NSString *)text
                 pictureUrl:(NSURL *)pictureUrl
                   videoUrl:(NSURL *)videoUrl
                    linkUrl:(NSURL *)linkUrl
                   linkName:(NSString *)linkName
                linkCaption:(NSString *)linkCaption
            linkDescription:(NSString *)linkDescription
             enableTracking:(BOOL)enableTracking
                  userToken:(NSString *)userToken
               publishToken:(NSString *)publishToken
                toProviders:(NSArray *)providers
                   callback:(OAMessagePostCallback)complete
{
    NSDictionary *postDict = [self createPostDictionary:text
                                             pictureUrl:pictureUrl
                                               videoUrl:videoUrl
                                                linkUrl:linkUrl
                                               linkName:linkName
                                            linkCaption:linkCaption
                                        linkDescription:linkDescription
                                         enableTracking:enableTracking
                                              userToken:userToken
                                              providers:providers];

    if (!postDict)
    {
        return false;
    }

    self.callback = complete;

    NSString *ep = [NSString stringWithFormat:kApiEndpoint, userToken];

    NSDictionary *headers =
            @{kHttpHeaderAuthorization: [NSString stringWithFormat:@"%@ %@", kOAPublishAuthType, publishToken]};

    return [self createConnectionForEndpoint:ep
                                  withMethod:HTTP_METHOD_POST
                            andUrlParameters:nil
                                   anonymous:true
                                  andHeaders:headers
                              andJsonPayload:postDict
                            andBinaryPayload:nil];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    OALog(@"Message posting failed: %@, %@", error, error.userInfo);

    [super connection:connection didFailWithError:error];
    if (self.callback)
    {
        self.callback(NO, nil, [OAError errorWithError:error]);
        self.callback = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    OALog(@"Message posting finished with status %d", (int)self.statusCode);

    [super connectionDidFinishLoading:connection];

    OAMessagePostResult *result = [self parseResponse:self.response[@"result"][@"data"][@"sharing_message"]];

    BOOL success = (self.statusCode == HTTP_STATUS_CODE_OK || self.statusCode == HTTP_STATUS_CODE_MULTI_STATUS);

    OAError *err;

    if (!success)
    {
        err = [OAError errorWithMessage:self.response[@"request"][@"status"][@"info"]
                                andCode:OA_ERROR_MESSAGE_POST_FAIL];
    }

    if (self.callback)
    {
        self.callback(!success, result, err);
        self.callback = nil;
    }
}

#pragma mark - Utilities

/* parse publish result for single provider */
- (OAMessagePostProviderResult *)parseMessagePublication:(NSDictionary *)pub
{
    OAMessagePostProviderResult *result = [[OAMessagePostProviderResult alloc] init];
    result.flag = pub[@"status"][@"flag"];
    result.code = [pub[@"status"][@"code"] integerValue];
    result.success = [result.flag isEqualToString:@"success"] && result.code == HTTP_STATUS_CODE_OK;
    result.message = pub[@"status"][@"message"];
    result.provider = pub[@"provider"];
    return result;
}

/* parse the response for all the providers */
- (OAMessagePostResult *)parseResponse:(NSDictionary *)respMessage
{
    OAMessagePostResult *resp = [[OAMessagePostResult alloc] init];
    resp.messageToken = respMessage[@"sharing_message_token"];
    resp.wholeResponse = respMessage;

    NSArray *publicationsArray = respMessage[@"publications"][@"entries"];
    if ([publicationsArray isKindOfClass:[NSArray class]])
    {
        NSMutableArray *parsedArray = [NSMutableArray arrayWithCapacity:[publicationsArray count]];
        [publicationsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            OAMessagePostProviderResult *pub = [self parseMessagePublication:obj];
            [parsedArray addObject:pub];
        }];
        resp.providerResults = [NSArray arrayWithArray:parsedArray];
    }
    return resp;
}

/* create HTTP request POST dictionary */
- (NSDictionary *)createPostDictionary:(NSString *)text
                            pictureUrl:(NSURL *)pictureUrl
                              videoUrl:(NSURL *)videoUrl
                               linkUrl:(NSURL *)linkUrl
                              linkName:(NSString *)linkName
                           linkCaption:(NSString *)linkCaption
                       linkDescription:(NSString *)linkDescription
                        enableTracking:(BOOL)enableTracking
                             userToken:(NSString *)userToken
                             providers:(NSArray *)providers
{

    if (!userToken)
    {
        OALogError(@"When sharing user_token should be set. user_token=%@", userToken);
        return nil;
    }

    NSMutableDictionary *contentsDictionary = [NSMutableDictionary dictionary];
    if (text)
    {
        contentsDictionary[@"text"] = [NSMutableDictionary dictionaryWithObject:text forKey:@"body"];
    }
    if (pictureUrl)
    {
        contentsDictionary[@"picture"] =
        [NSMutableDictionary dictionaryWithObject:[pictureUrl absoluteString] forKey:@"url"];
    }
    if (videoUrl)
    {
        contentsDictionary[@"video"] =
        [NSMutableDictionary dictionaryWithObject:[videoUrl absoluteString] forKey:@"url"];
    }
    if (linkUrl)
    {
        contentsDictionary[@"link"] = [NSMutableDictionary dictionaryWithObject:[linkUrl absoluteString] forKey:@"url"];
        if (linkName)
        {
            contentsDictionary[@"link"][@"name"] = linkName;
        }
        if (linkCaption)
        {
            contentsDictionary[@"link"][@"caption"] = linkCaption;
        }
        if (linkDescription)
        {
            contentsDictionary[@"link"][@"description"] = linkDescription;
        }
    }
    contentsDictionary[@"flags"] = @{@"enable_tracking": enableTracking ? @"1" : @"0"};

    NSDictionary *paramDict = @{ @"request": @{
        @"message": @{
            @"providers": providers,
            @"parts": contentsDictionary
        }
    }};

    return paramDict;
}

@end
