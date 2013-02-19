//
//  Stolperstein.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Stolperstein.h"

@implementation Stolperstein

- (NSString *)locationStreetName
{
    NSRange range = [self.locationStreet rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet];
    NSString *locationStreetName = self.locationStreet;
    if (range.location != NSNotFound) {
        locationStreetName = [locationStreetName substringToIndex:range.location];
        locationStreetName = [locationStreetName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }
    return locationStreetName;
}

- (NSString *)title
{
    return self.personName;
}

- (NSString *)subtitle
{
    NSMutableString *subtitle = [NSMutableString stringWithString:self.locationStreet];
    if (self.locationZipCode || self.locationCity) {
        [subtitle appendString:@","];
        
        if (self.locationZipCode) {
            [subtitle appendFormat:@" %@", self.locationZipCode];
        }
        if (self.locationCity) {
            [subtitle appendFormat:@" %@", self.locationCity];
        }
    }
    
    return subtitle;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinates.coordinate;
}

@end
