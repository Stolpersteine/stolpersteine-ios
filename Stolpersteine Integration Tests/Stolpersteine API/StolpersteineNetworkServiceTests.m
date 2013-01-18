//
//  Stolpersteine_Unit_Tests.m
//  Stolpersteine Unit Tests
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineNetworkServiceTests.h"

#import "Stolperstein.h"
#import "StolpersteineNetworkService.h"

static NSString * const BASE_URL = @"https://stolpersteine-optionu.rhcloud.com/api/";

#ifdef DEBUG
@interface NSURLRequest (HTTPS)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end
#endif

@interface StolpersteineNetworkServiceTests()

@property (nonatomic, strong) StolpersteineNetworkService *networkService;
@property (nonatomic, assign) BOOL done;

@end

@implementation StolpersteineNetworkServiceTests

- (void)setUp
{
    [super setUp];
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the traffic.
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:url.host];
#endif
    
    self.networkService = [[StolpersteineNetworkService alloc] initWithURL:url clientUser:nil clientPassword:nil];
    self.done = FALSE;
}

- (BOOL)waitForCompletion:(NSTimeInterval)timeoutSecs
{
    NSDate *timeoutDate = [NSDate dateWithTimeIntervalSinceNow:timeoutSecs];
    
    do {
        [NSRunLoop.currentRunLoop runMode:NSDefaultRunLoopMode beforeDate:timeoutDate];
        if (timeoutDate.timeIntervalSinceNow < 0.0) {
            break;
        }
    } while (!self.done);
    
    return self.done;
}

- (void)testRetrieveStolpersteine
{
    [self.networkService retrieveStolpersteineWithSearchData:nil page:0 pageSize:0 completionHandler:^(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error) {
        self.done = TRUE;
        
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        if (stolpersteine.count > 0) {
            Stolperstein *stolperstein = [stolpersteine objectAtIndex:0];
            
            // Mandatory fields
            STAssertNotNil(stolperstein.id, @"Wrong ID");
            STAssertTrue([stolperstein.id isKindOfClass:NSString.class], @"Wrong type for ID");
            STAssertNotNil(stolperstein.personFirstName, @"Wrong first name");
            STAssertTrue([stolperstein.personFirstName isKindOfClass:NSString.class], @"Wrong type for first name");
            STAssertNotNil(stolperstein.personLastName, @"Wrong last name");
            STAssertTrue([stolperstein.personLastName isKindOfClass:NSString.class], @"Wrong type for last name");
            STAssertNotNil(stolperstein.locationStreet, @"Wrong street");
            STAssertTrue([stolperstein.locationStreet isKindOfClass:NSString.class], @"Wrong type for street");
            STAssertNotNil(stolperstein.locationCity, @"Wrong city");
            STAssertTrue([stolperstein.locationCity isKindOfClass:NSString.class], @"Wrong type for city");
            STAssertNotNil(stolperstein.locationZipCode, @"Wrong zip code");
            STAssertTrue([stolperstein.locationZipCode isKindOfClass:NSString.class], @"Wrong type for zip code");
            STAssertNotNil(stolperstein.locationCoordinates, @"Wrong coordinates");
            STAssertTrue([stolperstein.locationCoordinates isKindOfClass:CLLocation.class], @"Wrong type for coordinates");
            STAssertNotNil(stolperstein.sourceRetrievedAt, @"Wrong retrieved at date");
            STAssertTrue([stolperstein.sourceRetrievedAt isKindOfClass:NSDate.class], @"Wrong type for retrieved at date");
            STAssertNotNil(stolperstein.sourceURLString, @"Wrong source URL string");
            STAssertTrue([stolperstein.sourceURLString isKindOfClass:NSString.class], @"Wrong type for source URL string");
            STAssertTrue([stolperstein.sourceURLString hasPrefix:@"http"], @"Wrong content source URL string");
            STAssertNotNil(stolperstein.sourceName, @"Wrong source name");
            STAssertTrue([stolperstein.sourceName isKindOfClass:NSString.class], @"Wrong type for source name");
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
