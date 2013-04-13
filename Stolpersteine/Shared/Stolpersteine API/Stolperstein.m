//
//  Stolperstein.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Stolperstein.h"

@implementation Stolperstein

- (BOOL)isEqual:(id)other
{
    if (other == self)
        return YES;
    if (!other || ![other isKindOfClass:self.class])
        return NO;
    return [self isEqualToStolperstein:other];
}

- (BOOL)isEqualToStolperstein:(Stolperstein *)stolperstein
{
    if (self == stolperstein)
        return YES;
    if (![self.id isEqualToString:stolperstein.id])
        return NO;
    return YES;
}

- (NSUInteger)hash
{
    return self.id.hash;
}

- (CLLocationCoordinate2D)coordinate
{
    return self.locationCoordinate;
}

@end
