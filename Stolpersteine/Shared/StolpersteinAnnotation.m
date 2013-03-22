//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinAnnotation.h"

@implementation StolpersteinAnnotation

- (NSString *)title
{
    return @"StolpersteinAnnotation";
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%u", self.stolpersteine.count];
}

- (BOOL)isCluster
{
    return self.stolpersteine.count > 1;
}

@end
