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

- (void)testNewName
{
    Stolperstein *stolperstein;
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna Therese";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna Therese Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"von Müller";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna von Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = nil;
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = nil;
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Erna", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.type = StolpersteinTypeStolperschwelle;
        builder.personLastName = @"Gossner-Mission";
    }];
    XCTAssertEqualObjects([Localization newNameFromStolperstein:stolperstein], @"Gossner-Mission (Stolperschwelle)", @"Wrong name");
}

- (void)testNewShortName
{
    Stolperstein *stolperstein;
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna Therese";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"von Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. von Müller", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = nil;
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"Müller", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = nil;
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"Erna";
        builder.personLastName = @"";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E.", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"E.";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");

    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"E";
        builder.personLastName = @"Müller";
    }];
    XCTAssertEqualObjects([Localization newShortNameFromStolperstein:stolperstein], @"E. Müller", @"Wrong name");
}

- (void)testNewStreetName
{
    Stolperstein *stolperstein;
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Turmstraße 76a";
    }];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Turmstraße 10";
    }];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Turmstraße";
    }];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Turmstraße", @"Wrong street name");
    
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Alt-Moabit 11";
    }];
    XCTAssertEqualObjects([Localization newStreetNameFromStolperstein:stolperstein], @"Alt-Moabit", @"Wrong street name");
}

- (void)testNewAddressFromStolperstein
{
    Stolperstein *stolperstein;
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"", @"Wrong address");
    
    // No street
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationCity = @"Stadt";
    }];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Stadt", @"Wrong address");

    // City, but no zip code
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Straße 1";
        builder.locationCity = @"Stadt";
    }];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\nStadt", @"Wrong address");
    
    // Zip code, but no city
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Straße 1";
        builder.locationZipCode = @"12345";
    }];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\n12345", @"Wrong address");

    // Both city and zip code
    stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.locationStreet = @"Straße 1";
        builder.locationZipCode = @"12345";
        builder.locationCity = @"Stadt";
    }];
    address = [Localization newLongAddressFromStolperstein:stolperstein];
    XCTAssertEqualObjects(address, @"Straße 1\n12345 Stadt", @"Wrong address");
}

@end
