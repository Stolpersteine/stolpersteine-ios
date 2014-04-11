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

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super init];
    if (self) {
        _ID = [decoder decodeObjectForKey:@"ID"];
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

+ (instancetype)stolpersteinWithBuilderBlock:(void(^)(StolpersteinComponents *builder))builderBlock
{
    NSParameterAssert(builderBlock);
    
    StolpersteinComponents *builder = [[StolpersteinComponents alloc] init];
    builderBlock(builder);
    
    return [builder stolperstein];
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.ID forKey:@"ID"];
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

- (id)copyWithZone:(NSZone *)zone
{
    return self;    // immutable
}

- (BOOL)isEqual:(id)other
{
    BOOL isEqual;
    
    if (other == self) {
        isEqual = YES;
    } else if (![other isKindOfClass:self.class]) {
        isEqual = NO;
    } else {
        isEqual = [self isEqualToStolperstein:other];
    }
    
    return isEqual;
}

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein
{
    BOOL isEqual;
    
    if (stolperstein == nil) {
        isEqual = NO;
    } else {
        isEqual = ((_ID == stolperstein->_ID) || [_ID isEqualToString:stolperstein->_ID]) &&
            (_type == stolperstein->_type) &&
            ((_sourceName == stolperstein->_sourceName) || [_sourceName isEqualToString:stolperstein->_sourceName]) &&
            ((_sourceURLString == stolperstein->_sourceURLString) || [_sourceURLString isEqualToString:stolperstein->_sourceURLString]) &&
            ((_personFirstName == stolperstein->_personFirstName) || [_personFirstName isEqualToString:stolperstein->_personFirstName]) &&
            ((_personLastName == stolperstein->_personLastName) || [_personLastName isEqualToString:stolperstein->_personLastName]) &&
            ((_personBiographyURLString == stolperstein->_personBiographyURLString) || [_personBiographyURLString isEqualToString:stolperstein->_personBiographyURLString]) &&
            ((_locationStreet == stolperstein->_locationStreet) || [_locationStreet isEqualToString:stolperstein->_locationStreet]) &&
            ((_locationZipCode == stolperstein->_locationZipCode) || [_locationZipCode isEqualToString:stolperstein->_locationZipCode]) &&
            ((_locationCity == stolperstein->_locationCity) || [_locationCity isEqualToString:stolperstein->_locationCity]) &&
            (_locationCoordinate.latitude == stolperstein->_locationCoordinate.latitude) &&
            (_locationCoordinate.longitude == stolperstein->_locationCoordinate.longitude);
    }
    
    return isEqual;
}

- (NSUInteger)hash
{
    return self.ID.hash;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

@end

@implementation StolpersteinComponents

- (Stolperstein *)stolperstein
{
    return [[Stolperstein alloc] initWithID:self.ID
                                       type:self.type
                                 sourceName:self.sourceName
                            sourceURLString:self.sourceURLString
                            personFirstName:self.personFirstName
                             personLastName:self.personLastName
                   personBiographyURLString:self.personBiographyURLString
                             locationStreet:self.locationStreet
                            locationZipCode:self.locationZipCode
                               locationCity:self.locationCity
                         locationCoordinate:self.locationCoordinate];
}

@end