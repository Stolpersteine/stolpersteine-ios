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

- (void)testNewStreetName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    
    stolperstein.locationStreet = @"Turmstraße 76a";
    STAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein.locationStreet = @"Turmstraße 10";
    STAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein.locationStreet = @"Turmstraße";
    STAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein.locationStreet = @"Alt-Moabit 11";
    STAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Alt-Moabit", @"Wrong street name");
}

- (void)testNewAddressFromStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"", @"Wrong address");
    
    // No street
    stolperstein.locationStreet = nil;
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = nil;
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Stadt", @"Wrong address");

    // City, but no zip code
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = nil;
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\nStadt", @"Wrong address");
    
    // Zip code, but no city
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = nil;
    stolperstein.locationZipCode = @"12345";
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\n12345", @"Wrong address");

    // Both city and zip code
    stolperstein.locationStreet = @"Straße 1";
    stolperstein.locationCity = @"Stadt";
    stolperstein.locationZipCode = @"12345";
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    STAssertEqualObjects(address, @"Straße 1\n12345 Stadt", @"Wrong address");
}

@end
