//
//  NSDictionary+Parsing.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NSDictionary+Parsing.h"

#import "Stolperstein.h"

@implementation NSDictionary (Parsing)

- (Stolperstein *)newStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.id = [self valueForKeyPath:@"_id"];
    stolperstein.personFirstName = [self valueForKeyPath:@"person.name"];
    stolperstein.personLastName = [self valueForKeyPath:@"person.name"];
    stolperstein.locationStreet = [self valueForKeyPath:@"location.street"];
    stolperstein.locationZipCode = [self valueForKeyPath:@"location.zipCode"];
    stolperstein.locationCity = [self valueForKeyPath:@"location.city"];
    
    NSString *latitudeAsString = [self valueForKeyPath:@"location.coordinates.latitude"];
    NSString *longitudeAsString = [self valueForKeyPath:@"location.coordinates.longitude"];
    if (latitudeAsString && longitudeAsString) {
        stolperstein.locationCoordinates = [[CLLocation alloc] initWithLatitude:latitudeAsString.doubleValue longitude:longitudeAsString.doubleValue];
    }
    
    return stolperstein;
}

@end
