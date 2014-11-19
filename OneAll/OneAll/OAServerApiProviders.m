//
// Created by Uri Kogan on 19/11/14.
// Copyright (c) 2014 urk. All rights reserved.
//
#import "OAServerApiProviders.h"
#import "OALog.h"
#import "OAProvider.h"

/** API endpoint to use for data retrieval when logging in using OA web form */
static NSString *const kApiEndpoint = @"providers.json";

@interface OAServerApiProviders () <NSURLConnectionDataDelegate>

/** callback for operation completion */
@property (strong, nonatomic) OAServerApiProvidersCallback callback;

@end

@implementation OAServerApiProviders

- (BOOL)read:(OAServerApiProvidersCallback)callback
{
    self.callback = callback;

    OALog(@"Getting providers list");

    return [self createConnectionForEndpoint:kApiEndpoint
                                  withMethod:HTTP_METHOD_GET
                            andUrlParameters:nil
                                   anonymous:true
                                  andHeaders:nil
                              andJsonPayload:nil
                            andBinaryPayload:nil];
}

#pragma mark - NSURLConnectionDataDelegate

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    OALogError(@"Failed to get provider names: %@, %@", error.localizedDescription, error.userInfo);
    [super connection:connection didFailWithError:error];
    if (self.callback)
    {
        self.callback(nil, [OAError errorWithError:error]);
        self.callback = nil;
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [super connectionDidFinishLoading:connection];

    OALog(@"Read provider names from the server with status: %d", (int) self.statusCode);

    if (self.statusCode != HTTP_STATUS_CODE_OK)
    {
        if (self.callback)
        {
            self.callback(nil,
                    [OAError errorWithMessage:@"Failed to read providers" andCode:OA_ERROR_CONNECTION_ERROR]);

            self.callback = nil;
        }
        return;
    }

    NSMutableArray *pvs = [NSMutableArray array];

    [self.response[@"result"][@"data"][@"providers"][@"entries"] enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop)
    {
        OAProvider *p = [OAProvider providerType:obj[@"key"]
                                            name:obj[@"name"]
                                    isConfigured:[self.class parseBool:obj[@"configuration"][@"is_completed"]]
                         isConfigurationRequired:[self.class parseBool:obj[@"configuration"][@"is_required"]]
                               userInputRequired:[self.class parseBool:obj[@"authentication"][@"is_user_input_required"]]
                                  userInputTitle:obj[@"authentication"][@"user_input_type"]];
        [pvs addObject:p];
    }];

    if (self.callback)
    {
        self.callback(pvs, nil);
        self.callback = nil;
    }
}

@end