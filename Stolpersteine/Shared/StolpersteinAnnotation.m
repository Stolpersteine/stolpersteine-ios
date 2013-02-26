//
//  StolpersteinAnnotation.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinAnnotation.h"

#import "Stolperstein.h"

@implementation StolpersteinAnnotation

- (id)initWithStolperstein:(Stolperstein *)stolperstein
{
    self = [super init];
    if (self) {
        self.stolperstein = stolperstein;
    }
    
    return self;
}

- (NSString *)title
{
    return [NSString stringWithFormat:@"%@ %@", self.stolperstein.personFirstName, self.stolperstein.personLastName];
}

- (NSString *)subtitle
{
    NSMutableString *subtitle = [NSMutableString stringWithString:self.stolperstein.locationStreet];
    if (self.stolperstein.locationZipCode || self.stolperstein.locationCity) {
        [subtitle appendString:@","];
        
        if (self.stolperstein.locationZipCode) {
            [subtitle appendFormat:@" %@", self.stolperstein.locationZipCode];
        }
        if (self.stolperstein.locationCity) {
            [subtitle appendFormat:@" %@", self.stolperstein.locationCity];
        }
    }
    
    return subtitle;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.stolperstein.locationCoordinates.coordinate;
}

- (void)setCoordinate:(CLLocationCoordinate2D)coordinate
{
    self.stolperstein.locationCoordinates = [[CLLocation alloc] initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
}

@end
