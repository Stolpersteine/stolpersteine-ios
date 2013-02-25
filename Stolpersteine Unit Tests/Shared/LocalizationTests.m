//
//  LocalizationTests.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "LocalizationTests.h"

#import "Localization.h"
#import "Stolperstein.h"

@implementation LocalizationTests

- (void)testNewAddressFromStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    NSString *address = [Localization newAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"", @"Wrong address");
    
    // No street
    stolperstein.locationStreet = nil;
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = nil;
    address = [Localization newAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Stadt", @"Wrong address");

    // City, but no zip code
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = nil;
    address = [Localization newAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\nStadt", @"Wrong address");
    
    // Zip code, but no city
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = nil;
    stolperstein.locationZipCode = @"12345";
    address = [Localization newAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\n12345", @"Wrong address");

    // Both city and zip code
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = @"12345";
    address = [Localization newAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\n12345 Stadt", @"Wrong address");
}

@end
