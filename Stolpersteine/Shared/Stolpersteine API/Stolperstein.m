//
//  Stolperstein.m
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

@interface Stolperstein()

@property (nonatomic, copy) NSString *personBiographyURLString;

@end

@implementation Stolperstein

- (id)initWithID:(NSString *)ID
            type:(StolpersteinType)type
 sourceURLString:(NSString *)sourceURLString
      sourceName:(NSString *)sourceName
 personFirstName:(NSString *)personFirstName
  personLastName:(NSString *)personLastName
personBiographyURLString:(NSString *)personBiographyURLString
  locationStreet:(NSString *)locationStreet
 locationZipCode:(NSString *)locationZipCode
    locationCity:(NSString *)locationCity
locationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super init];
    if (self) {
        _ID = ID;
        _type = type;
        _sourceURLString = sourceURLString;
        _sourceName = sourceName;
        _personFirstName = personFirstName;
        _personLastName = personLastName;
        _personBiographyURLString = personBiographyURLString;
        _locationStreet = locationStreet;
        _locationZipCode = locationZipCode;
        _locationCity = locationCity;
        _locationCoordinate = locationCoordinate;
    }
    
    return self;
}

- (BOOL)isEqual:(id)other
{
    BOOL isEqual;
    
    if (other == self) {
        isEqual = YES;
    } else if (!other || ![other isKindOfClass:self.class]) {
        isEqual = NO;
    } else {
        isEqual = [self isEqualToStolperstein:other];
    }
    
    return isEqual;
}

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein
{
    BOOL isEqual = [self.ID isEqualToString:stolperstein.ID];
    return isEqual;
}

- (NSUInteger)hash
{
    return self.ID.hash;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;    // immutable
}

- (NSString *)personBiographyURLString
{
    NSString *personBiographyURLString = _personBiographyURLString;
    
    // Use English website for Berlin biographies if not using German
    NSArray *preferredLanguages = NSLocale.preferredLanguages;
    if (preferredLanguages.count > 0 && ![preferredLanguages[0] hasPrefix:@"de"]) {
        static NSString *prefixGerman = @"http://www.stolpersteine-berlin.de/de";
        static NSString *prefixEnglish = @"http://www.stolpersteine-berlin.de/en";
        if ([personBiographyURLString hasPrefix:prefixGerman]) {
            NSRange range = NSMakeRange(0, prefixGerman.length);
            personBiographyURLString = [personBiographyURLString stringByReplacingCharactersInRange:range withString:prefixEnglish];
        }
    }
    
    return personBiographyURLString;
}

- (NSString *)title
{
    return nil;
}

- (NSString *)subtitle
{
    return nil;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

@end
