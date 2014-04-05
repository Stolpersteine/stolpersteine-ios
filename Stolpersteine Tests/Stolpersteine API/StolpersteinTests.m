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

- (Stolperstein *)newStolpersteinwithID:(NSString *)ID
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:ID
                                                             type:StolpersteinTypeStolperstein
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:nil
                                                   personLastName:nil
                                         personBiographyURLString:nil
                                                   locationStreet:nil
                                                  locationZipCode:nil
                                                     locationCity:nil
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (void)testEqual
{
    Stolperstein *stolperstein0, *stolperstein1;
    
    // IDs match
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:@"123"];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein1], @"Wrong equality");
    XCTAssertTrue([stolperstein1 isEqual:stolperstein0], @"Wrong equality");
    XCTAssertTrue(stolperstein0.hash == stolperstein1.hash, @"Wrong hash");

    // Object equals itself
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein0], @"Wrong equality");
    XCTAssertTrue(stolperstein0.hash == stolperstein0.hash, @"Wrong hash");

    // IDs don't match
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:@"456"];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");
    XCTAssertFalse([stolperstein1 isEqual:stolperstein0], @"Wrong equality");
    XCTAssertFalse(stolperstein0.hash == stolperstein1.hash, @"Wrong hash"); // not required, but preferable

    // Wrong class
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:@"456"];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1.ID], @"Wrong equality");
    XCTAssertFalse([stolperstein1 isEqual:stolperstein0.ID], @"Wrong equality");

    // nil IDs
    stolperstein0 = [self newStolpersteinwithID:nil];
    stolperstein1 = [self newStolpersteinwithID:@"456"];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:nil];
    XCTAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    stolperstein0 = [self newStolpersteinwithID:nil];
    stolperstein1 = [self newStolpersteinwithID:nil];
    XCTAssertTrue([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    // nil objects
    XCTAssertFalse([(id)nil isEqual:stolperstein1], @"Wrong equality");
    XCTAssertFalse([stolperstein0 isEqual:nil], @"Wrong equality");
    XCTAssertFalse([(id)nil isEqual:nil], @"Wrong equality");
}

- (void)testEqualToStolpersteinID
{
    Stolperstein *stolperstein0, *stolperstein1;
    
    // IDs match
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:@"123"];
    XCTAssertTrue([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    XCTAssertTrue([stolperstein1 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    XCTAssertTrue(stolperstein0.hash == stolperstein1.hash, @"Wrong hash");
    
    // Object equals itself
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    XCTAssertTrue([stolperstein0 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    XCTAssertTrue(stolperstein0.hash == stolperstein0.hash, @"Wrong hash");
    
    // IDs don't match
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:@"456"];
    XCTAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    XCTAssertFalse([stolperstein1 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    XCTAssertFalse(stolperstein0.hash == stolperstein1.hash, @"Wrong hash"); // not required, but preferable

    // nil IDs
    stolperstein0 = [self newStolpersteinwithID:nil];
    stolperstein1 = [self newStolpersteinwithID:@"456"];
    XCTAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    stolperstein0 = [self newStolpersteinwithID:@"123"];
    stolperstein1 = [self newStolpersteinwithID:nil];
    XCTAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    stolperstein0 = [self newStolpersteinwithID:nil];
    stolperstein1 = [self newStolpersteinwithID:nil];
    XCTAssertTrue([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    // nil objects
    XCTAssertFalse([(id)nil isEqualToStolperstein:stolperstein1], @"Wrong equality");
    XCTAssertFalse([stolperstein0 isEqualToStolperstein:nil], @"Wrong equality");
    XCTAssertFalse([(id)nil isEqualToStolperstein:nil], @"Wrong equality");
}

@end