//
//  StolpersteineDataServiceTests.m
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

#import "StolpersteineDataService.h"
#import "Stolperstein.h"

#import <XCTest/XCTest.h>

@interface StolpersteineDataServiceTests : XCTestCase

@property (nonatomic, strong) StolpersteineDataService *dataService;
@property (nonatomic, assign) BOOL done;

@end

@implementation StolpersteineDataServiceTests

- (void)setUp
{
    [super setUp];
    
    self.dataService = [[StolpersteineDataService alloc] init];
    self.dataService.cacheEnabled = NO;
    
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

- (void)testStolpersteineLifecycle
{
    Stolperstein *stolpersteinToCreate = [[Stolperstein alloc] init];
    stolpersteinToCreate.id = @"123";
    stolpersteinToCreate.personFirstName = @"abc";
    
    self.done = NO;
    [self.dataService createStolpersteine:@[stolpersteinToCreate] completionHandler:^(NSError *error) {
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    self.done = NO;
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.id completionHandler:^(Stolperstein *stolperstein) {
        self.done = YES;
        
        XCTAssertEqualObjects(stolpersteinToCreate, stolperstein);
        XCTAssertEqualObjects(stolpersteinToCreate.personFirstName, stolperstein.personFirstName);
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
    
    self.done = NO;
    [self.dataService deleteStolpersteine:@[stolpersteinToCreate] completionHandler:^(NSError *error) {
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    self.done = NO;
    [self.dataService retrieveStolpersteinWithID:stolpersteinToCreate.id completionHandler:^(Stolperstein *stolperstein) {
        self.done = YES;
        
        XCTAssertNil(stolperstein);
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

- (void)testRetrieveStolpersteine
{
    NSMutableArray *stolpersteineToCreate = [NSMutableArray array];
    for (NSUInteger i = 0; i < 10; i++) {
        Stolperstein *stolperstein = [[Stolperstein alloc] init];
        stolperstein.id = @(i).stringValue;
        [stolpersteineToCreate addObject:stolperstein];
    }
    
    self.done = NO;
    [self.dataService createStolpersteine:stolpersteineToCreate completionHandler:^(NSError *error) {
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    self.done = NO;
    NSRange range = NSMakeRange(2, 5);
    [self.dataService retrieveStolpersteineWithRange:range completionHandler:^(NSArray *stolpersteine) {
        self.done = YES;
        
        XCTAssertEqual(stolpersteine.count, range.length);
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");

    self.done = NO;
    [self.dataService deleteStolpersteine:stolpersteineToCreate completionHandler:^() {
        self.done = YES;
    }];
    XCTAssertTrue([self waitForCompletion:5.0], @"Time out");
}

@end
