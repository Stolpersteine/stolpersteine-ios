//
//  StolpersteinTests.m
//  Stolpersteine
//
//  Created by Claus on 05.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinTests.h"

#import "Stolperstein.h"

@implementation StolpersteinTests

- (void)testLocationStreetName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];

    stolperstein.locationStreet = @"Turmstraße 76a";
    STAssertEqualObjects(stolperstein.locationStreetName, @"Turmstraße", @"Wrong street name");

    stolperstein.locationStreet = @"Turmstraße 10";
    STAssertEqualObjects(stolperstein.locationStreetName, @"Turmstraße", @"Wrong street name");

    stolperstein.locationStreet = @"Turmstraße";
    STAssertEqualObjects(stolperstein.locationStreetName, @"Turmstraße", @"Wrong street name");

    stolperstein.locationStreet = @"Alt-Moabit 11";
    STAssertEqualObjects(stolperstein.locationStreetName, @"Alt-Moabit", @"Wrong street name");
}

@end
