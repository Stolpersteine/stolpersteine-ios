//
//  StolpersteineNetworkService.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineNetworkService.h"

#import "AFJSONRequestOperation.h"
#import "AFHTTPClient.h"
#import "Stolperstein.h"

@interface StolpersteineNetworkService ()

@property (nonatomic, strong) AFHTTPClient *httpClient;

@end

@implementation StolpersteineNetworkService

- (id)initWithURL:(NSURL *)url clientUser:(NSString *)clientUser clientPassword:(NSString *)clientPassword
{
    if (self = [super init]) {
        self.httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
        self.httpClient.parameterEncoding = AFJSONParameterEncoding;
        [self.httpClient registerHTTPOperationClass:AFJSONRequestOperation.class];
    }
    
    return self;
}

- (void)retrieveStolpersteineWithSearchData:(SearchData *)searchData page:(NSUInteger)page pageSize:(NSUInteger)pageSize completionHandler:(void (^)(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error))completionHandler
{
    NSURLRequest *request = [self.httpClient requestWithMethod:@"GET" path:@"stolpersteine" parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSArray *stolpersteineAsJSON = JSON;
        for (NSDictionary *stolpersteinAsJSON in stolpersteineAsJSON) {
            Stolperstein *stolperstein = [[Stolperstein alloc] init];
            stolperstein.id = [stolpersteinAsJSON valueForKeyPath:@"_id"];
            stolperstein.personFirstName = [stolpersteinAsJSON valueForKeyPath:@"person.name"];
            stolperstein.personLastName = [stolpersteinAsJSON valueForKeyPath:@"person.name"];
            stolperstein.locationStreet = [stolpersteinAsJSON valueForKeyPath:@"location.street"];
            stolperstein.locationZipCode = [stolpersteinAsJSON valueForKeyPath:@"location.zipCode"];
            stolperstein.locationCity = [stolpersteinAsJSON valueForKeyPath:@"location.city"];
            
            NSString *latitudeAsString = [stolpersteinAsJSON valueForKeyPath:@"location.coordinates.latitude"];
            NSString *longitudeAsString = [stolpersteinAsJSON valueForKeyPath:@"location.coordinates.longitude"];
            if (latitudeAsString && longitudeAsString) {
                stolperstein.locationCoordinates = [[CLLocation alloc] initWithLatitude:latitudeAsString.doubleValue longitude:longitudeAsString.doubleValue];
            }
            
            NSLog(@"%@", stolperstein.id);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error %@", error);
    }];
    [self.httpClient enqueueHTTPRequestOperation:operation];
}

@end
