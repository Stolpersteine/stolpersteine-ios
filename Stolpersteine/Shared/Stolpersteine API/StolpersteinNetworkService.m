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
#import "StolpersteinNetworkServiceDelegate.h"
#import "NSDictionary+StolpersteinParsing.h"
#import "Base64.h"

static NSString * const API_URL = @"https://stolpersteine-api.eu01.aws.af.cm/v1";

@interface StolpersteinNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSString *encodedClientCredentials;

@end

@implementation StolpersteinNetworkService

- (id)initWithClientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    self = [super init];
    if (self) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
        
        if (clientUser && clientPassword) {
            self.encodedClientCredentials = [[[NSString stringWithFormat:@"%@:%@", clientUser, clientPassword] dataUsingEncoding:NSUTF8StringEncoding] base64EncodedString];
        }

        self.defaultSearchData = [[StolpersteinSearchData alloc] init];
        
        AFNetworkActivityIndicatorManager.sharedManager.enabled = YES;
    }
    
    return self;
}

- (void)setAllowsInvalidSSLCertificate:(BOOL)allowsInvalidSSLCertificate
{
    self.httpClient.allowsInvalidSSLCertificate = allowsInvalidSSLCertificate;
}

- (BOOL)allowsInvalidSSLCertificate
{
    return self.httpClient.allowsInvalidSSLCertificate;
}

- (void)addBasicAuthHeaderToRequest:(NSMutableURLRequest *)request
{
    if (self.encodedClientCredentials) {
        NSString *basicHeader = [NSString stringWithFormat:@"Basic %@", self.encodedClientCredentials];
        [request setValue:basicHeader forHTTPHeaderField:@"Authorization"];
    }
}

- (void)handleGlobalError:(NSError *)error
{
    if ([self.delegate respondsToSelector:@selector(stolpersteinNetworkService:handleError:)]) {
        if ([error.domain isEqualToString:AFNetworkingErrorDomain] && error.code != NSURLErrorCancelled) {
            [self.delegate stolpersteinNetworkService:self handleError:error];
        }
    }
}

- (NSOperation *)retrieveStolpersteineWithSearchData:(StolpersteinSearchData *)searchData range:(NSRange)range completionHandler:(BOOL (^)(NSArray *stolpersteine, NSError *error))completionHandler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // Optional parameters
    NSString *keyword = searchData.keyword ? searchData.keyword : self.defaultSearchData.keyword;
    if (keyword) {
        [parameters setObject:keyword forKey:@"q"];
    }
    NSString *street = searchData.street ? searchData.street : self.defaultSearchData.street;
    if (street) {
        [parameters setObject:street forKey:@"street"];
    }
    NSString *city = searchData.city ? searchData.city : self.defaultSearchData.city;
    if (city) {
        [parameters setObject:city forKey:@"city"];
    }
    
    // Mandatory parameters
    [parameters setObject:@(range.length) forKey:@"limit"];
    [parameters setObject:@(range.location) forKey:@"offset"];
    
    // Issue request
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
        BOOL shouldRunGlobalErrorHandler = YES;
        if (completionHandler) {
            shouldRunGlobalErrorHandler = completionHandler(nil, error);
        }
        
        if (shouldRunGlobalErrorHandler) {
            [self handleGlobalError:error];
        }
    }];

    operation.allowsInvalidSSLCertificate = self.httpClient.allowsInvalidSSLCertificate;
    [self.httpClient enqueueHTTPRequestOperation:operation];
    
    return operation;
}

@end
