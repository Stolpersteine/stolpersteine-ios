//
//  Localization.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Localization.h"

#import "Stolperstein.h"

@implementation Localization

+ (NSString *)newNameFromStolperstein:(Stolperstein *)stolperstein
{
    return [NSString stringWithFormat:@"%@ %@", stolperstein.personFirstName, stolperstein.personLastName];
}

+ (NSString *)newAddressShortFromStolperstein:(Stolperstein *)stolperstein
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

+ (NSString *)newAddressLongFromStolperstein:(Stolperstein *)stolperstein
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

@end
