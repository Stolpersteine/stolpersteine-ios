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

- (NSDate *)newDateForKeyPath:(NSString *)keyPath
{
    NSString *dateAsString = [self valueForKeyPath:keyPath];
    if ([dateAsString hasSuffix:@"Z"]) {
        dateAsString = [[dateAsString substringToIndex:dateAsString.length - 1] stringByAppendingString:@"GMT"];
    }

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
    NSDate *date = [dateFormatter dateFromString:dateAsString];
    return date;
}

- (Stolperstein *)newStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.id = [self valueForKeyPath:@"id"];
    stolperstein.imageURLString = [self valueForKeyPath:@"imageUrl"];
    stolperstein.text = [self valueForKeyPath:@"description"];
    stolperstein.personFirstName = [self valueForKeyPath:@"person.firstName"];
    stolperstein.personLastName = [self valueForKeyPath:@"person.lastName"];
    stolperstein.locationStreet = [self valueForKeyPath:@"location.street"];
    stolperstein.locationZipCode = [self valueForKeyPath:@"location.zipCode"];
    stolperstein.locationCity = [self valueForKeyPath:@"location.city"];
    stolperstein.sourceURLString = [self valueForKeyPath:@"source.url"];
    stolperstein.sourceName = [self valueForKeyPath:@"source.name"];
    stolperstein.sourceRetrievedAt = [self newDateForKeyPath:@"source.retrievedAt"];
    
    NSString *latitudeAsString = [self valueForKeyPath:@"location.coordinates.latitude"];
    NSString *longitudeAsString = [self valueForKeyPath:@"location.coordinates.longitude"];
    if (latitudeAsString && longitudeAsString) {
        stolperstein.locationCoordinates = [[CLLocation alloc] initWithLatitude:latitudeAsString.doubleValue longitude:longitudeAsString.doubleValue];
    }
    
    return stolperstein;
}

@end
