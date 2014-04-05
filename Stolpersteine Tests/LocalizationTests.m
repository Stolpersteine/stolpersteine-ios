//
//  LocalizationTests.m
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

#import "Localization.h"
#import "Stolperstein.h"

#import "OCMock.h"

#import <XCTest/XCTest.h>

@interface LocalizationTests : XCTestCase

@end

@implementation LocalizationTests

- (Stolperstein *)newStolpersteinWithPersonFirstName:(NSString *)personFirstName personLastName:(NSString *)personLastName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:nil
                                                             type:StolpersteinTypeStolperstein
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:personFirstName
                                                   personLastName:personLastName
                                         personBiographyURLString:nil
                                                   locationStreet:nil
                                                  locationZipCode:nil
                                                     locationCity:nil
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (Stolperstein *)newStolpersteinTypeStolperschwelleWithPersonLastName:(NSString *)personLastName
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:nil
                                                             type:StolpersteinTypeStolperschwelle
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:nil
                                                   personLastName:personLastName
                                         personBiographyURLString:nil
                                                   locationStreet:nil
                                                  locationZipCode:nil
                                                     locationCity:nil
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (Stolperstein *)newStolpersteinWithLocationStreet:(NSString *)locationStreet locationZipCode:(NSString *)locationZipCode locationCity:(NSString *)locationCity
{
    Stolperstein *stolperstein = [[Stolperstein alloc] initWithID:nil
                                                             type:StolpersteinTypeStolperstein
                                                       sourceName:nil
                                                  sourceURLString:nil
                                                  personFirstName:nil
                                                   personLastName:nil
                                         personBiographyURLString:nil
                                                   locationStreet:locationStreet
                                                  locationZipCode:locationZipCode
                                                     locationCity:locationCity
                                               locationCoordinate:CLLocationCoordinate2DMake(0, 0)];
    return stolperstein;
}

- (void)testNewName
{
    Stolperstein *stolperstein;
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna Therese" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Therese Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@"von Müller"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna von Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:nil personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:nil];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@""];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");
    
    stolperstein = [self newStolpersteinTypeStolperschwelleWithPersonLastName:@"Gossner-Mission"];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Gossner-Mission (Stolperschwelle)", @"Wrong name");
}

- (void)testNewShortName
{
    Stolperstein *stolperstein;
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna Therese" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@"von Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. von Müller", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:nil personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:nil];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"Erna" personLastName:@""];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"E." personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");

    stolperstein = [self newStolpersteinWithPersonFirstName:@"E" personLastName:@"Müller"];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
}

- (void)testNewStreetName
{
    Stolperstein *stolperstein;
    
    stolperstein = [self newStolpersteinWithLocationStreet:@"Turmstraße 76a" locationZipCode:nil locationCity:nil];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [self newStolpersteinWithLocationStreet:@"Turmstraße 10" locationZipCode:nil locationCity:nil];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [self newStolpersteinWithLocationStreet:@"Turmstraße" locationZipCode:nil locationCity:nil];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [self newStolpersteinWithLocationStreet:@"Alt-Moabit 11" locationZipCode:nil locationCity:nil];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Alt-Moabit", @"Wrong street name");
}

- (void)testNewAddressFromStolperstein
{
    Stolperstein *stolperstein;
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"", @"Wrong address");
    
    // No street
    stolperstein = [self newStolpersteinWithLocationStreet:nil locationZipCode:nil locationCity:@"Stadt"];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Stadt", @"Wrong address");

    // City, but no zip code
    stolperstein = [self newStolpersteinWithLocationStreet:@"Straße 1" locationZipCode:nil locationCity:@"Stadt"];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\nStadt", @"Wrong address");
    
    // Zip code, but no city
    stolperstein = [self newStolpersteinWithLocationStreet:@"Straße 1" locationZipCode:@"12345" locationCity:nil];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\n12345", @"Wrong address");

    // Both city and zip code
    stolperstein = [self newStolpersteinWithLocationStreet:@"Straße 1" locationZipCode:@"Stadt" locationCity:@"12345"];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\n12345 Stadt", @"Wrong address");
}

@end
