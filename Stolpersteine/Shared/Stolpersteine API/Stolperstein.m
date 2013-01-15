//
//  Stolperstein.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Stolperstein.h"

@implementation Stolperstein

- (NSString *)title
{
    NSString *title = [NSString stringWithFormat:@"%@ %@", self.personFirstName, self.personLastName];
    return title;
}

- (NSString *)subtitle
{
    return self.locationStreet;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinates.coordinate;
}

@end
