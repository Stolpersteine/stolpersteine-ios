//
//  StolpersteineNetworkService.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "NSDictionary+Parsing.h"

@interface StolpersteineNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;

@end

@implementation StolpersteineNetworkService

- (id)initWithURL:(NSURL *)url clientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
        
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    }
    
    return self;
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
    NSURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:@"stolpersteine" parameters:parameters];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, NSArray *stolpersteineAsJSON) {
        NSMutableArray *stolpersteine = [NSMutableArray arrayWithCapacity:stolpersteineAsJSON.count];
        for (NSDictionary *stolpersteinAsJSON in stolpersteineAsJSON) {
            Stolperstein *stolperstein = [stolpersteinAsJSON newStolperstein];
            [stolpersteine addObject:stolperstein];
        }
        
        if (completionHandler) {
            completionHandler(stolpersteine, nil);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (completionHandler) {
            completionHandler(nil, error);
        }
    }];

    [self.httpClient enqueueHTTPRequestOperation:operation];
    
    return operation;
}

@end
