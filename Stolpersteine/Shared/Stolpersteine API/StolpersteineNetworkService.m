//
//  StolpersteineNetworkService.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "StolpersteineNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "AFHTTPClient.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "Stolperstein.h"
#import "StolpersteineSearchData.h"
#import "StolpersteineNetworkServiceDelegate.h"
#import "NSDictionary+StolpersteinParsing.h"

static NSString * const API_URL = @"http://api.stolpersteineapp.org/v1";

@interface StolpersteineNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;
@property (nonatomic, strong) NSString *encodedClientCredentials;

@end

@implementation StolpersteineNetworkService

- (instancetype)initWithClientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    self = [super init];
    if (self) {
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:API_URL]];
        _httpClient.parameterEncoding = AFJSONParameterEncoding;
        [_httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
        
        if (clientUser && clientPassword) {
            NSString *clientCredentials = [NSString stringWithFormat:@"%@:%@", clientUser, clientPassword];
            _encodedClientCredentials = [[clientCredentials dataUsingEncoding:NSUTF8StringEncoding] base64EncodedStringWithOptions:0];
        }

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

- (NSOperation *)retrieveStolpersteineWithSearchData:(StolpersteineSearchData *)searchData range:(NSRange)range completionHandler:(BOOL (^)(NSArray *stolpersteine, NSError *error))completionHandler
{
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];
    
    // Optional parameters
    NSString *keyword = searchData.keywordsString ? searchData.keywordsString : self.defaultSearchData.keywordsString;
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
        if (error) {
            NSLog(@"Error: %@", error);
        }
        
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
