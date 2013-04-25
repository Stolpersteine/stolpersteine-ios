//
//  Localization.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Localization.h"

#import "Stolperstein.h"
#import "MapClusteringAnnotation.h"

@implementation Localization

+ (NSString *)newNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *firstName = [NSMutableString stringWithCapacity:stolperstein.personFirstName.length + stolperstein.personLastName.length + 1];
    if (stolperstein.personFirstName.length > 0) {
        if (stolperstein.personLastName.length > 0) {
            [firstName appendFormat:@"%@ ", stolperstein.personFirstName];
        } else {
            [firstName appendString:stolperstein.personFirstName];
        }
    }
    
    if (stolperstein.personLastName) {
        [firstName appendString:stolperstein.personLastName];
    }
    
    return firstName;
}

+ (NSString *)newShortNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *firstNameShort = [NSMutableString stringWithCapacity:stolperstein.personLastName.length + 3];
    BOOL hasFirstLetter = (stolperstein.personFirstName.length > 0);
    if (hasFirstLetter) {
        if (stolperstein.personLastName.length > 0) {
            [firstNameShort appendFormat:@"%@. ", [stolperstein.personFirstName substringToIndex:1]];
        } else {
            [firstNameShort appendFormat:@"%@.", [stolperstein.personFirstName substringToIndex:1]];
        }
    }
    
    if (stolperstein.personLastName) {
        [firstNameShort appendString:stolperstein.personLastName];
    }
    
    return firstNameShort;
}

+ (NSString *)newStreetNameFromStolperstein:(Stolperstein *)stolperstein
{
    NSRange range = [stolperstein.locationStreet rangeOfCharacterFromSet:NSCharacterSet.decimalDigitCharacterSet];
    NSString *locationStreetName = stolperstein.locationStreet;
    if (range.location != NSNotFound) {
        locationStreetName = [locationStreetName substringToIndex:range.location];
        locationStreetName = [locationStreetName stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceCharacterSet];
    }
    return locationStreetName;
}

+ (NSString *)newShortAddressFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *address = [NSMutableString stringWithString:stolperstein.locationStreet];
    if (stolperstein.locationZipCode || stolperstein.locationCity) {
        [address appendString:@","];
        
        if (stolperstein.locationZipCode) {
            [address appendFormat:@" %@", stolperstein.locationZipCode];
        }
        if (stolperstein.locationCity) {
            [address appendFormat:@" %@", stolperstein.locationCity];
        }
    }
    
    return address;
}

+ (NSString *)newLongAddressFromStolperstein:(Stolperstein *)stolperstein
{
    NSMutableString *address = [NSMutableString stringWithCapacity:20];
    
    if (stolperstein.locationStreet) {
        [address appendString:stolperstein.locationStreet];
    }
    
    if (stolperstein.locationZipCode) {
        [address appendString:@"\n"];
        [address appendFormat:@"%@", stolperstein.locationZipCode];
    }
    
    if (stolperstein.locationCity) {
        if (stolperstein.locationStreet && !stolperstein.locationZipCode) {
            [address appendString:@"\n"];
        }
        
        if (stolperstein.locationZipCode) {
            [address appendString:@" "];
        }
        
        if (stolperstein.locationCity) {
            [address appendString:stolperstein.locationCity];
        }
    }
    return address;
}

+ (NSString *)newDescriptionFromStolperstein:(Stolperstein *)stolperstein
{
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    NSString *address = [Localization newShortAddressFromStolperstein:stolperstein];
    return [NSString stringWithFormat:@"%@, %@", name, address];
}

+ (NSString *)newTitleFromMapCulsteringAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation
{
    NSString *title;
    if (mapClusteringAnnotation.isCluster) {
        NSUInteger numStolpersteine = MIN(mapClusteringAnnotation.annotations.count, 5);
        NSArray *stolpersteine = [mapClusteringAnnotation.annotations subarrayWithRange:NSMakeRange(0, numStolpersteine)];
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:numStolpersteine];
        for (Stolperstein *stolperstein in stolpersteine) {
            [names addObject:[Localization newShortNameFromStolperstein:stolperstein]];
        }
        title = [names componentsJoinedByString:@", "];
    } else {
        Stolperstein *stolperstein = mapClusteringAnnotation.annotations[0];
        title = [Localization newNameFromStolperstein:stolperstein];
    }
    
    return title;
}

+ (NSString *)newSubtitleFromMapCulsteringAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation
{
    NSString *subtitle;
    if (mapClusteringAnnotation.isCluster) {
        subtitle = [NSString stringWithFormat:@"%u Stolpersteine", mapClusteringAnnotation.annotations.count];
    } else {
        Stolperstein *stolperstein = mapClusteringAnnotation.annotations[0];
        subtitle = [Localization newShortAddressFromStolperstein:stolperstein];
    }
    
    return subtitle;
}

@end
