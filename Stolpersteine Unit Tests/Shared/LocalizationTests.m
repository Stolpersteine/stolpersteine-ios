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

- (void)testNewName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    
    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Müller", @"Wrong name");
    
    stolperstein.personFirstName = @"Erna Therese";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Therese Müller", @"Wrong name");
    
    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"von Müller";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna von Müller", @"Wrong name");
    
    stolperstein.personFirstName = nil;
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");
    
    stolperstein.personFirstName = @"";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = nil;
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");
    
    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"";
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");

    stolperstein.personFirstName = nil;
    stolperstein.personLastName = @"Gossner-Mission";
    stolperstein.type = StolpersteinTypeStolperschwelle;
    STAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Gossner-Mission (Stolperschwelle)", @"Wrong name");
}

- (void)testNewShortName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    
    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein.personFirstName = @"Erna Therese";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"von Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. von Müller", @"Wrong name");

    stolperstein.personFirstName = nil;
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein.personFirstName = @"";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = nil;
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein.personFirstName = @"Erna";
    stolperstein.personLastName = @"";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein.personFirstName = @"E.";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");

    stolperstein.personFirstName = @"E";
    stolperstein.personLastName = @"Müller";
    STAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
}

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
