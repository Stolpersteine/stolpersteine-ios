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
    NSString *personFormat;
    if (self.stolpersteine.count == 1) {
        personFormat = NSLocalizedString(@"%d individual", nil);
    } else {
        personFormat = NSLocalizedString(@"%d individuals", nil);
    }
    
    NSString *title = [NSString stringWithFormat:personFormat, self.stolpersteine.count];
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
