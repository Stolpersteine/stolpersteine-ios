//
//  StolpersteinClusterAnntation.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinClusterAnnotation.h"

@implementation StolpersteinClusterAnnotation

- (NSString *)title
{
    return @"StolpersteinClusterAnnotation";
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%u", self.stolpersteinAnnotations.count];
}

@end
