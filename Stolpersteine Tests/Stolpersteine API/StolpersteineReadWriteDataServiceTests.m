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

- (void)setUp
{
    [super setUp];
    
    self.dataService = [[StolpersteineReadWriteDataService alloc] init];
    self.dataService.cacheEnabled = NO;
    self.dataService.synchronous = YES;
}

- (void)testStolpersteineLifecycle
{
    Stolperstein *stolpersteinToCreate = [[Stolperstein alloc] init];
    stolpersteinToCreate.id = @"123";
    stolpersteinToCreate.personFirstName = @"abc";
    
    __block BOOL done = NO;
    [self.dataService createStolpersteine:@[stolpersteinToCreate] completionHandler:^() {
        done = YES;
    }];
    XCTAssertTrue(done);

    done = NO;
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.id completionHandler:^(Stolperstein *stolperstein) {
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
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.id completionHandler:^(Stolperstein *stolperstein) {
        done = YES;
        
        XCTAssertNil(stolperstein);
    }];
    XCTAssertTrue(done);
}

- (void)testRetrieveStolpersteine
{
    NSMutableArray *stolpersteineToCreate = [NSMutableArray array];
    for (NSUInteger i = 0; i < 10; i++) {
        Stolperstein *stolperstein = [[Stolperstein alloc] init];
        stolperstein.id = @(i).stringValue;
        [stolpersteineToCreate addObject:stolperstein];
    }
    
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];

    NSRange range = NSMakeRange(2, 5);
    [self.dataService retrieveStolpersteineWithRange:range completionHandler:^(NSArray *stolpersteine) {
        XCTAssertEqual(stolpersteine.count, range.length);
    }];

    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineKeyword
{
    Stolperstein *stolperstein0 = [[Stolperstein alloc] init];
    stolperstein0.id = @"0";
    stolperstein0.personFirstName = @"Erna";
    Stolperstein *stolperstein1 = [[Stolperstein alloc] init];
    stolperstein1.personLastName = @"Ernas";
    stolperstein1.id = @"1";
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];
 
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] init];
    searchData.keyword = @"ern";
    [self.dataService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 10) completionHandler:^(NSArray *stolpersteine) {
        XCTAssertTrue([stolpersteine containsObject:stolperstein0]);
        XCTAssertTrue([stolpersteine containsObject:stolperstein1]);
    }];

    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

- (void)testRetrieveStolpersteineKeywordMultiple
{
    Stolperstein *stolperstein0 = [[Stolperstein alloc] init];
    stolperstein0.id = @"0";
    stolperstein0.personFirstName = @"Erna";
    Stolperstein *stolperstein1 = [[Stolperstein alloc] init];
    stolperstein1.personLastName = @"Meier";
    stolperstein1.id = @"1";
    NSArray *stolpersteineToCreate = @[stolperstein0, stolperstein1];
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:NULL];
    
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] init];
    searchData.keyword = @"ern mei";
    [self.dataService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 10) completionHandler:^(NSArray *stolpersteine) {
        XCTAssertTrue([stolpersteine containsObject:stolperstein0]);
        XCTAssertTrue([stolpersteine containsObject:stolperstein1]);
    }];
    
    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:NULL];
}

@end
