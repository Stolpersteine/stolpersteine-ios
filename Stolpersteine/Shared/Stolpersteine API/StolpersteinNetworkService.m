//
//  StolpersteineNetworkService.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "NSDictionary+Parsing.h"
#import "Base64.h"

@interface StolpersteinNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSString *encodedCredentials;

@end

@implementation StolpersteinNetworkService

- (id)initWithURL:(NSURL *)url clientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
        
        if (clientUser && clientPassword) {
            self.encodedCredentials = [[[NSString stringWithFormat:@"%@:%@", clientUser, clientPassword] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
        }
        
        AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
    }
    
    return self;
}

- (void)addBasicAuthHeaderToRequest:(NSMutableURLRequest *)request
{
    if (self.encodedCredentials) {
        NSString *basicHeader = [NSString stringWithFormat:@"Basic %@", self.encodedCredentials];
        [request setValue:basicHeader forHTTPHeaderField:@"Authorization"];
    }
}

- (NSOperation *)retrieveStolpersteineWithSearchData:(StolpersteinSearchData *)searchData range:(NSRange)range completionHandler:(void (^)(NSArray *stolpersteine, NSError *error))completionHandler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    if (searchData.keyword) {
        [parameters setObject:searchData.keyword forKey:@"q"];
    }
    if (searchData.locationStreet) {
        [parameters setObject:searchData.locationStreet forKey:@"street"];
    }
    [parameters setObject:@(range.length) forKey:@"limit"];
    [parameters setObject:@(range.location) forKey:@"offset"];
    NSMutableURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:@"stolpersteine" parameters:parameters];
    [self addBasicAuthHeaderToRequest:request];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *stolpersteineAsJSON) {
        // Parse on background thread
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^{
            NSMutableArray *stolpersteine = [NSMutableArray arrayWithCapacity:stolpersteineAsJSON.count];
            for (NSDictionary *stolpersteinAsJSON in stolpersteineAsJSON) {
                Stolperstein *stolperstein = [stolpersteinAsJSON newStolperstein];
                [stolpersteine addObject:stolperstein];
            }

            if (completionHandler) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    completionHandler(stolpersteine, nil);
                });
            }
        });
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];

    [self.httpClient enqueueHTTPRequestOperation:operation];
    
    return operation;
}

@end
