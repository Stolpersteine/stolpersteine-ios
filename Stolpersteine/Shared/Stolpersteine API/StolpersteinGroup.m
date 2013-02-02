//
//  StolpersteineGroup.m
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinGroup.h"

@implementation StolpersteinGroup

- (NSString *)title
{
    NSString *person = self.stolpersteine.count <= 1 ? @"Mensch" : @"Menschen";
    NSString *title = [NSString stringWithFormat:@"%d %@", self.stolpersteine.count, person];
    return title;
}

- (NSString *)subtitle
{
    return nil;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinates.coordinate;
}

@end
