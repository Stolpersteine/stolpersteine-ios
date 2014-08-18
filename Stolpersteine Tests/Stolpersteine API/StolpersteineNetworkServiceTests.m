//
//  StolpersteineNetworkServiceTests.m
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

#import "Stolperstein.h"
#import "StolpersteineSearchData.h"
#import "StolpersteineNetworkService.h"

#import <XCTest/XCTest.h>

static NSString * const BASE_URL = @"https://stolpersteine-api.eu01.aws.af.cm/v1";

@interface StolpersteineNetworkServiceTests : XCTestCase

@property (nonatomic) StolpersteineNetworkService *networkService;
@property (nonatomic) BOOL done;

@end

@implementation StolpersteineNetworkServiceTests

- (void)setUp
{
    [super setUp];

    self.networkService = [[StolpersteineNetworkService alloc] initWithClientUser:nil clientPassword:nil];
    self.networkService.allowsInvalidSSLCertificate = YES;
    
    self.done = NO;
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
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertTrue(stolpersteine.count == 5, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            // Mandatory fields
            XCTAssertNotNil(stolperstein.ID, @"Wrong ID");
            XCTAssertTrue([stolperstein.ID isKindOfClass:NSString.class], @"Wrong type for ID");
            XCTAssertTrue(stolperstein.type == StolpersteinTypeStolperstein || stolperstein.type == StolpersteinTypeStolperschwelle, @"Wrong type");
            XCTAssertNotNil(stolperstein.sourceName, @"Wrong source name");
            XCTAssertTrue([stolperstein.sourceName isKindOfClass:NSString.class], @"Wrong type for source name");
            XCTAssertNotNil(stolperstein.sourceURL, @"Wrong source url");
            XCTAssertTrue([stolperstein.sourceURL isKindOfClass:NSURL.class], @"Wrong type for source url");
            XCTAssertNotNil(stolperstein.personFirstName, @"Wrong first name");
            XCTAssertTrue([stolperstein.personFirstName isKindOfClass:NSString.class], @"Wrong type for first name");
            XCTAssertNotNil(stolperstein.personLastName, @"Wrong last name");
            XCTAssertTrue([stolperstein.personLastName isKindOfClass:NSString.class], @"Wrong type for last name");
            XCTAssertNotNil(stolperstein.personBiographyURL, @"Wrong biography url");
            XCTAssertTrue([stolperstein.personBiographyURL isKindOfClass:NSURL.class], @"Wrong type for biography URL");
            XCTAssertNotNil(stolperstein.locationStreet, @"Wrong street");
            XCTAssertTrue([stolperstein.locationStreet isKindOfClass:NSString.class], @"Wrong type for street");
            XCTAssertNotNil(stolperstein.locationCity, @"Wrong city");
            XCTAssertTrue([stolperstein.locationCity isKindOfClass:NSString.class], @"Wrong type for city");
            XCTAssertTrue(stolperstein.locationCoordinate.latitude != 0, @"Wrong coordinates");
            XCTAssertTrue(stolperstein.locationCoordinate.longitude != 0, @"Wrong coordinates");
            
            // Optional fields
            if (stolperstein.locationZipCode) {
                XCTAssertTrue([stolperstein.locationZipCode isKindOfClass:NSString.class], @"Wrong type for zip code");
            }
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineKeyword
{
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:@"Ern" street:nil city:nil];
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.personFirstName hasPrefix:searchData.keywordsString];
            found |= [stolperstein.personLastName hasPrefix:searchData.keywordsString];
            XCTAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineStreet
{
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:@"Turmstraße" city:nil];
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.locationStreet hasPrefix:searchData.street];
            XCTAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCity
{
    StolpersteineSearchData *defaultSearchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:@"xyz"];
    self.networkService.defaultSearchData = defaultSearchData;    // will be overridden by specific search data
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:@"Berlin"];
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.locationCity hasPrefix:searchData.city];
            XCTAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCityInvalid
{
    StolpersteineSearchData *defaultSearchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:@"Berlin"];
    self.networkService.defaultSearchData = defaultSearchData;    // will be overridden by specific search data
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:@"xyz"];
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertEqual(stolpersteine.count, 0u, @"Wrong number of stolpersteine");
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCityDefaultInvalid
{
    StolpersteineSearchData *defaultSearchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:@"xyz"];
    self.networkService.defaultSearchData = defaultSearchData;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertEqual(stolpersteine.count, 0u, @"Wrong number of stolpersteine");
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteinePaging
{
    // Load first two stolpersteine
    __block NSString *stolpersteineID0, *stolpersteineID1;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 2) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertEqual(stolpersteine.count, 2u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 2) {
            stolpersteineID0 = [stolpersteine[0] ID];
            stolpersteineID1 = [stolpersteine[1] ID];
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    // First page
    self.done = NO;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 1) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertEqual(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            XCTAssertEqualObjects(stolpersteineID0, [stolpersteine[0] ID], @"Wrong stolpersteine ID");
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    // Second page
    self.done = NO;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(1, 1) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        XCTAssertNil(error, @"Error request");
        XCTAssertEqual(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            XCTAssertEqualObjects(stolpersteineID1, [stolpersteine[0] ID], @"Wrong stolpersteine ID");
        }
        
        return NO;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
