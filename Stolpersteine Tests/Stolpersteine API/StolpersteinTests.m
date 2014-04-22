//
//  StolpersteinTests.m
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

#import <XCTest/XCTest.h>

@interface StolpersteinTests : XCTestCase

@end

@implementation StolpersteinTests

- (void)testEqual
{
    Stolperstein *stolperstein0, *stolperstein1;
    
    // IDs match
    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein1]);
    XCTAssertTrue([stolperstein1 isEqual:stolperstein0]);
    XCTAssertTrue(stolperstein0.hash == stolperstein1.hash);

    // Object equals itself
    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein0]);
    XCTAssertTrue(stolperstein0.hash == stolperstein0.hash);

    // IDs don't match
    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"456";
    }];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1]);
    XCTAssertFalse([stolperstein1 isEqual:stolperstein0]);
    XCTAssertFalse(stolperstein0.hash == stolperstein1.hash); // not required, but preferable

    // Wrong class
    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"456";
    }];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1.ID]);
    XCTAssertFalse([stolperstein1 isEqual:stolperstein0.ID]);

    // nil IDs
    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"456";
    }];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1]);

    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.ID = @"123";
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
    }];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1]);

    stolperstein0 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
    }];
    stolperstein1 = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
    }];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein1]);

    // nil objects
    XCTAssertFalse([(id)nil isEqual:stolperstein1]);
    XCTAssertFalse([stolperstein0 isEqual:nil]);
    XCTAssertFalse([(id)nil isEqual:nil]);
}

@end