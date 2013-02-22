//
//  Stolpersteine_Unit_Tests.m
//  Stolpersteine Unit Tests
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineNetworkServiceTests.h"

#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
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
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 5) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            // Mandatory fields
            STAssertNotNil(stolperstein.id, @"Wrong ID");
            STAssertTrue([stolperstein.id isKindOfClass:NSString.class], @"Wrong type for ID");
            STAssertNotNil(stolperstein.personFirstName, @"Wrong name");
            STAssertTrue([stolperstein.personFirstName isKindOfClass:NSString.class], @"Wrong type for first name");
            STAssertNotNil(stolperstein.personLastName, @"Wrong name");
            STAssertTrue([stolperstein.personLastName isKindOfClass:NSString.class], @"Wrong type for last name");
            STAssertNotNil(stolperstein.personBiographyURLString, @"Wrong name");
            STAssertTrue([stolperstein.personBiographyURLString isKindOfClass:NSString.class], @"Wrong type for biography URL");
            STAssertNotNil(stolperstein.locationStreet, @"Wrong street");
            STAssertTrue([stolperstein.locationStreet isKindOfClass:NSString.class], @"Wrong type for street");
            STAssertNotNil(stolperstein.locationCity, @"Wrong city");
            STAssertTrue([stolperstein.locationCity isKindOfClass:NSString.class], @"Wrong type for city");
            STAssertNotNil(stolperstein.locationCoordinates, @"Wrong coordinates");
            STAssertTrue([stolperstein.locationCoordinates isKindOfClass:CLLocation.class], @"Wrong type for coordinates");
            STAssertNotNil(stolperstein.sourceRetrievedAt, @"Wrong retrieved at date");
            STAssertTrue([stolperstein.sourceRetrievedAt isKindOfClass:NSDate.class], @"Wrong type for retrieved at date");
            STAssertNotNil(stolperstein.sourceURLString, @"Wrong source URL string");
            STAssertTrue([stolperstein.sourceURLString isKindOfClass:NSString.class], @"Wrong type for source URL string");
            STAssertTrue([stolperstein.sourceURLString hasPrefix:@"http"], @"Wrong content source URL string");
            STAssertNotNil(stolperstein.sourceName, @"Wrong source name");
            STAssertTrue([stolperstein.sourceName isKindOfClass:NSString.class], @"Wrong type for source name");
            
            // Optional fields
            if (stolperstein.imageURLString) {
                STAssertTrue([stolperstein.imageURLString isKindOfClass:NSString.class], @"Wrong type for image URL string");
                STAssertTrue([stolperstein.imageURLString hasPrefix:@"http"], @"Wrong content image URL string");
            }
            
            if (stolperstein.text) {
                STAssertTrue([stolperstein.text isKindOfClass:NSString.class], @"Wrong type for text");
            }
            
            if (stolperstein.locationZipCode) {
                STAssertTrue([stolperstein.locationZipCode isKindOfClass:NSString.class], @"Wrong type for zip code");
            }
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineKeyword
{
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = @"Ern";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.personFirstName hasPrefix:searchData.keyword];
            found |= [stolperstein.personLastName hasPrefix:searchData.keyword];
            STAssertTrue(found, @"Wrong search result");
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineStreet
{
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.locationStreet = @"Turmstraße";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.locationStreet hasPrefix:searchData.locationStreet];
            STAssertTrue(found, @"Wrong search result");
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteinePaging
{
    // Load first two stolpersteine
    __block NSString *stolpersteineID0, *stolpersteineID1;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 2) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 2u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 2) {
            stolpersteineID0 = [stolpersteine[0] id];
            stolpersteineID1 = [stolpersteine[1] id];
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");

    // First page
    self.done = FALSE;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 1) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            STAssertEqualObjects(stolpersteineID0, [stolpersteine[0] id], @"Wrong stolpersteine ID");
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");

    // Second page
    self.done = FALSE;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(1, 1) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.done = TRUE;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            STAssertEqualObjects(stolpersteineID1, [stolpersteine[0] id], @"Wrong stolpersteine ID");
        }
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
