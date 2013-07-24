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

#import "StolpersteinTests.h"

#import "Stolperstein.h"

@implementation StolpersteinTests

- (void)testEqual
{
    Stolperstein *stolperstein0 = [[Stolperstein alloc] init];
    Stolperstein *stolperstein1 = [[Stolperstein alloc] init];
    
    // IDs match
    stolperstein0.id = @"123";
    stolperstein1.id = @"123";
    STAssertTrue([stolperstein0 isEqual:stolperstein1], @"Wrong equality");
    STAssertTrue([stolperstein1 isEqual:stolperstein0], @"Wrong equality");
    STAssertTrue(stolperstein0.hash == stolperstein1.hash, @"Wrong hash");

    // Object equals itself
    stolperstein0.id = @"123";
    STAssertTrue([stolperstein0 isEqual:stolperstein0], @"Wrong equality");
    STAssertTrue(stolperstein0.hash == stolperstein0.hash, @"Wrong hash");

    // IDs don't match
    stolperstein0.id = @"123";
    stolperstein1.id = @"456";
    STAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");
    STAssertFalse([stolperstein1 isEqual:stolperstein0], @"Wrong equality");
    STAssertFalse(stolperstein0.hash == stolperstein1.hash, @"Wrong hash"); // not required, but preferable

    // Wrong class
    stolperstein0.id = @"123";
    stolperstein1.id = @"456";
    STAssertFalse([stolperstein0 isEqual:stolperstein1.id], @"Wrong equality");
    STAssertFalse([stolperstein1 isEqual:stolperstein0.id], @"Wrong equality");

    // nil IDs
    stolperstein0.id = nil;
    stolperstein1.id = @"456";
    STAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    stolperstein0.id = @"123";
    stolperstein1.id = nil;
    STAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    stolperstein0.id = nil;
    stolperstein1.id = nil;
    STAssertFalse([stolperstein0 isEqual:stolperstein1], @"Wrong equality");

    // nil objects
    STAssertFalse([(id)nil isEqual:stolperstein1], @"Wrong equality");
    STAssertFalse([stolperstein0 isEqual:nil], @"Wrong equality");
    STAssertFalse([(id)nil isEqual:nil], @"Wrong equality");
}

- (void)testEqualToStolperstein
{
    Stolperstein *stolperstein0 = [[Stolperstein alloc] init];
    Stolperstein *stolperstein1 = [[Stolperstein alloc] init];
    
    // IDs match
    stolperstein0.id = @"123";
    stolperstein1.id = @"123";
    STAssertTrue([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    STAssertTrue([stolperstein1 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    STAssertTrue(stolperstein0.hash == stolperstein1.hash, @"Wrong hash");
    
    // Object equals itself
    stolperstein0.id = @"123";
    STAssertTrue([stolperstein0 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    STAssertTrue(stolperstein0.hash == stolperstein0.hash, @"Wrong hash");
    
    // IDs don't match
    stolperstein0.id = @"123";
    stolperstein1.id = @"456";
    STAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    STAssertFalse([stolperstein1 isEqualToStolperstein:stolperstein0], @"Wrong equality");
    STAssertFalse(stolperstein0.hash == stolperstein1.hash, @"Wrong hash"); // not required, but preferable

    // nil IDs
    stolperstein0.id = nil;
    stolperstein1.id = @"456";
    STAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    stolperstein0.id = @"123";
    stolperstein1.id = nil;
    STAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    stolperstein0.id = nil;
    stolperstein1.id = nil;
    STAssertFalse([stolperstein0 isEqualToStolperstein:stolperstein1], @"Wrong equality");
    
    // nil objects
    STAssertFalse([(id)nil isEqualToStolperstein:stolperstein1], @"Wrong equality");
    STAssertFalse([stolperstein0 isEqualToStolperstein:nil], @"Wrong equality");
    STAssertFalse([(id)nil isEqualToStolperstein:nil], @"Wrong equality");
}

@end