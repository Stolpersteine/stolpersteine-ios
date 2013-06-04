//
//  StolpersteinTests.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
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