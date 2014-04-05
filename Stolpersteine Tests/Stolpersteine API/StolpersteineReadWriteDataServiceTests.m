//
//  StolpersteineReadWriteDataServiceTests.m
//  Stolpersteine
//
//  Copyright (C) 2014 Option-U Software
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

#import "StolpersteineReadWriteDataService.h"
#import "StolpersteineSearchData.h"
#import "Stolperstein.h"

#import <XCTest/XCTest.h>

@interface StolpersteineReadWriteDataServiceTests : XCTestCase

@property (nonatomic, strong) StolpersteineReadWriteDataService *dataService;

@end

@implementation StolpersteineReadWriteDataServiceTests

- (Stolperstein *)newStolpersteinWithID:(NSString *)ID personFirstName:(NSString *)personFirstName personLastName:(NSString *)personLastName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:ID
                                                             type:StolpersteinTypeStolperstein
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:personFirstName
                                                   personLastName:personLastName
                                         personBiographyURLString:nil
                                                   locationStreet:nil
                                                  locationZipCode:nil
                                                     locationCity:nil
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (Stolperstein *)newStolpersteinWithID:(NSString *)ID locationStreet:(NSString *)locationStreet
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:ID
                                                             type:StolpersteinTypeStolperstein
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:nil
                                                   personLastName:nil
                                         personBiographyURLString:nil
                                                   locationStreet:locationStreet
                                                  locationZipCode:nil
                                                     locationCity:nil
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (void)setUp
{
    [super setUp];
    
    self.dataService = [[StolpersteineReadWriteDataService alloc] initWithName:@"debugDatabase.sqlite"];
    self.dataService.cacheEnabled = NO;
    self.dataService.synchronous = YES;
}

- (void)testStolpersteineLifecycle
{
    Stolperstein *stolpersteinToCreate = [self newStolpersteinWithID:@"123" personFirstName:@"abc" personLastName:nil];
    
    __block BOOL done = NO;
    [self.dataService createStolpersteine:@[stolpersteinToCreate] completionHandler:^() {
        done = YES;
    }];
    XCTAssertTrue(done);

    done = NO;
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.ID completionHandler:^(Stolperstein *stolperstein) {
        done = YES;
        
        XCTAssertEqualObjects(stolpersteinToCreate, stolperstein);
        XCTAssertEqualObjects(stolpersteinToCreate.personFirstName, stolperstein.personFirstName);
    }];
    XCTAssertTrue(done);
    
    done = NO;
    [self.dataService deleteStolpersteine:@[stolpersteinToCreate] completionHandler:^() {
        done = YES;
    }];
    XCTAssertTrue(done);

    done = NO;
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.ID completionHandler:^(Stolperstein *stolperstein) {
        done = YES;
        
        XCTAssertNil(stolperstein);
    }];
    XCTAssertTrue(done);
}

- (void)testRetrieveStolpersteine
{
    NSMutableArray *stolpersteineToCreate = [NSMutableArray array];
    for (NSUInteger i = 0; i < 10; i++) {
        Stolperstein *stolperstein = [self newStolpersteinWithID:@(i).stringValue personFirstName:nil personLastName:nil];
        [stolpersteineToCreate addObject:stolperstein];
    }
    
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];

    NSRange range = NSMakeRange(2, 5);
    [self.dataService retrieveStolpersteineWithRange:range completionHandler:^(NSArray *stolpersteine) {
        XCTAssertEqual(stolpersteine.count, range.length);
    }];

    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineKeywordsString
{
    Stolperstein *stolperstein0 = [self newStolpersteinWithID:@"0" personFirstName:@"Erna" personLastName:nil];
    Stolperstein *stolperstein1 = [self newStolpersteinWithID:@"1" personFirstName:nil personLastName:@"Ernas"];
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];

    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:@"ern" street:nil city:nil];
    [self.dataService retrieveStolpersteineWithSearchData:searchData limit:10 completionHandler:^(NSArray *stolpersteine) {
        XCTAssertTrue([stolpersteine containsObject:stolperstein0]);
        XCTAssertTrue([stolpersteine containsObject:stolperstein1]);
    }];

    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineKeywordsStringLimit
{
    Stolperstein *stolperstein0 = [self newStolpersteinWithID:@"0" personFirstName:@"Erna" personLastName:nil];
    Stolperstein *stolperstein1 = [self newStolpersteinWithID:@"1" personFirstName:nil personLastName:@"Ernas"];
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];
    
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:@"ern" street:nil city:nil];
    [self.dataService retrieveStolpersteineWithSearchData:searchData limit:1 completionHandler:^(NSArray *stolpersteine) {
        XCTAssertEqual(stolpersteine.count, 1u);
    }];
    
    
    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineKeywordsStringMultiple
{
    Stolperstein *stolperstein0 = [self newStolpersteinWithID:@"0" personFirstName:@"Erna" personLastName:nil];
    Stolperstein *stolperstein1 = [self newStolpersteinWithID:@"1" personFirstName:nil personLastName:@"Meier"];
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];
    
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:@"ern mei" street:nil city:nil];
    [self.dataService retrieveStolpersteineWithSearchData:searchData limit:10 completionHandler:^(NSArray *stolpersteine) {
        XCTAssertTrue([stolpersteine containsObject:stolperstein0]);
        XCTAssertTrue([stolpersteine containsObject:stolperstein1]);
    }];
    
    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineStreet
{
    Stolperstein *stolperstein0 = [self newStolpersteinWithID:@"0" locationStreet:@"straße"];
    Stolperstein *stolperstein1 = [self newStolpersteinWithID:@"1" personFirstName:nil personLastName:@"straße"];
    Stolperstein *stolperstein2 = [self newStolpersteinWithID:@"2" locationStreet:@"straß"];
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1, stolperstein2];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];
    
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:@"straß" city:nil];
    [self.dataService retrieveStolpersteineWithSearchData:searchData limit:10 completionHandler:^(NSArray *stolpersteine) {
        XCTAssertTrue([stolpersteine containsObject:stolperstein0]);
        XCTAssertFalse([stolpersteine containsObject:stolperstein1]);
        XCTAssertTrue([stolpersteine containsObject:stolperstein2]);
    }];
    
    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

@end
