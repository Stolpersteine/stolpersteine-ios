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

@implementation Stolperstein

- (id)initWithID:(NSString *)ID type:(StolpersteinType)type sourceName:(NSString *)sourceName sourceURLString:(NSString *)sourceURLString personFirstName:(NSString *)personFirstName personLastName:(NSString *)personLastName personBiographyURLString:(NSString *)personBiographyURLString locationStreet:(NSString *)locationStreet locationZipCode:(NSString *)locationZipCode locationCity:(NSString *)locationCity locationCoordinate:(CLLocationCoordinate2D)locationCoordinate
{
    self = [super init];
    if (self) {
        _id = ID;
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

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _id = [decoder decodeObjectForKey:@"id"];
        _type = [decoder decodeIntegerForKey:@"type"];
        _sourceURLString = [decoder decodeObjectForKey:@"sourceURLString"];
        _sourceName = [decoder decodeObjectForKey:@"sourceName"];
        _personFirstName = [decoder decodeObjectForKey:@"personFirstName"];
        _personLastName = [decoder decodeObjectForKey:@"personLastName"];
        _personBiographyURLString = [decoder decodeObjectForKey:@"personBiographyURLString"];
        _locationStreet = [decoder decodeObjectForKey:@"locationStreet"];
        _locationZipCode = [decoder decodeObjectForKey:@"locationZipCode"];
        _locationCity = [decoder decodeObjectForKey:@"locationCity"];
        _locationCoordinate.latitude = [decoder decodeDoubleForKey:@"locationCoordinate.latitude"];
        _locationCoordinate.longitude = [decoder decodeDoubleForKey:@"locationCoordinate.longitude"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.id forKey:@"id"];
    [coder encodeInteger:self.type forKey:@"type"];
    [coder encodeObject:self.sourceURLString forKey:@"sourceURLString"];
    [coder encodeObject:self.sourceName forKey:@"sourceName"];
    [coder encodeObject:self.personFirstName forKey:@"personFirstName"];
    [coder encodeObject:self.personLastName forKey:@"personLastName"];
    [coder encodeObject:self.personBiographyURLString forKey:@"personBiographyURLString"];
    [coder encodeObject:self.locationStreet forKey:@"locationStreet"];
    [coder encodeObject:self.locationZipCode forKey:@"locationZipCode"];
    [coder encodeObject:self.locationCity forKey:@"locationCity"];
    [coder encodeDouble:self.locationCoordinate.latitude forKey:@"locationCoordinate.latitude"];
    [coder encodeDouble:self.locationCoordinate.longitude forKey:@"locationCoordinate.longitude"];
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
    BOOL isEqual = [self.id isEqualToString:stolperstein.id];
    return isEqual;
}

- (NSUInteger)hash
{
    return self.id.hash;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

@end
