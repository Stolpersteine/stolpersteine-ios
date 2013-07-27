//
//  StolpersteinNetworkServiceTests.m
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

#import "StolpersteinNetworkServiceTests.h"

#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinNetworkService.h"

static NSString * const BASE_URL = @"https://stolpersteine-api.eu01.aws.af.cm/v1";

@interface StolpersteinNetworkServiceTests()

@property (nonatomic, strong) StolpersteinNetworkService *networkService;
@property (nonatomic, assign) BOOL done;

@end

@implementation StolpersteinNetworkServiceTests

- (void)setUp
{
    [super setUp];

    self.networkService = [[StolpersteinNetworkService alloc] initWithClientUser:nil clientPassword:nil];
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
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            // Mandatory fields
            STAssertNotNil(stolperstein.id, @"Wrong ID");
            STAssertTrue([stolperstein.id isKindOfClass:NSString.class], @"Wrong type for ID");
            STAssertTrue(stolperstein.type == StolpersteinTypeStolperstein || stolperstein.type == StolpersteinTypeStolperschwelle, @"Wrong type");
            STAssertNotNil(stolperstein.personFirstName, @"Wrong first name");
            STAssertTrue([stolperstein.personFirstName isKindOfClass:NSString.class], @"Wrong type for first name");
            STAssertNotNil(stolperstein.personLastName, @"Wrong last name");
            STAssertTrue([stolperstein.personLastName isKindOfClass:NSString.class], @"Wrong type for last name");
            STAssertNotNil(stolperstein.personBiographyURLString, @"Wrong biography url");
            STAssertTrue([stolperstein.personBiographyURLString isKindOfClass:NSString.class], @"Wrong type for biography URL");
            STAssertNotNil(stolperstein.locationStreet, @"Wrong street");
            STAssertTrue([stolperstein.locationStreet isKindOfClass:NSString.class], @"Wrong type for street");
            STAssertNotNil(stolperstein.locationCity, @"Wrong city");
            STAssertTrue([stolperstein.locationCity isKindOfClass:NSString.class], @"Wrong type for city");
            STAssertTrue(stolperstein.locationCoordinate.latitude != 0, @"Wrong coordinates");
            STAssertTrue(stolperstein.locationCoordinate.longitude != 0, @"Wrong coordinates");
            STAssertNotNil(stolperstein.sourceName, @"Wrong source name");
            STAssertTrue([stolperstein.sourceName isKindOfClass:NSString.class], @"Wrong type for source name");
            STAssertNotNil(stolperstein.sourceURLString, @"Wrong source url");
            STAssertTrue([stolperstein.sourceURLString isKindOfClass:NSString.class], @"Wrong type for source url");
            
            // Optional fields
            if (stolperstein.text) {
                STAssertTrue([stolperstein.text isKindOfClass:NSString.class], @"Wrong type for text");
            }
            
            if (stolperstein.locationZipCode) {
                STAssertTrue([stolperstein.locationZipCode isKindOfClass:NSString.class], @"Wrong type for zip code");
            }
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineKeyword
{
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = @"Ern";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.personFirstName hasPrefix:searchData.keyword];
            found |= [stolperstein.personLastName hasPrefix:searchData.keyword];
            STAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineStreet
{
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.street = @"Turmstraße";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.locationStreet hasPrefix:searchData.street];
            STAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCity
{
    self.networkService.defaultSearchData.city = @"xyz";    // will be overridden by specific search data
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.city = @"Berlin";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertTrue(stolpersteine.count > 0, @"Wrong number of stolpersteine");
        for (Stolperstein *stolperstein in stolpersteine) {
            BOOL found = [stolperstein.locationCity hasPrefix:searchData.city];
            STAssertTrue(found, @"Wrong search result");
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCityInvalid
{
    self.networkService.defaultSearchData.city = @"Berlin";    // will be overridden by specific search data
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.city = @"xyz";
    [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 0u, @"Wrong number of stolpersteine");
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteineCityDefaultInvalid
{
    self.networkService.defaultSearchData.city = @"xyz";
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 5) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 0u, @"Wrong number of stolpersteine");
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteinePaging
{
    // Load first two stolpersteine
    __block NSString *stolpersteineID0, *stolpersteineID1;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 2) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 2u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 2) {
            stolpersteineID0 = [stolpersteine[0] id];
            stolpersteineID1 = [stolpersteine[1] id];
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");

    // First page
    self.done = NO;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 1) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            STAssertEqualObjects(stolpersteineID0, [stolpersteine[0] id], @"Wrong stolpersteine ID");
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");

    // Second page
    self.done = NO;
    [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(1, 1) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.done = YES;
        
        STAssertNil(error, @"Error request");
        STAssertEquals(stolpersteine.count, 1u, @"Wrong number of stolpersteine");
        if (stolpersteine.count == 1) {
            STAssertEqualObjects(stolpersteineID1, [stolpersteine[0] id], @"Wrong stolpersteine ID");
        }
        
        return NO;
    }];
    STAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
