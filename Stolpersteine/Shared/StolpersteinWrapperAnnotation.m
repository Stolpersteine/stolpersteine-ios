//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinWrapperAnnotation.h"

@implementation StolpersteinWrapperAnnotation

- (NSString *)title
{
    return @"StolpersteinWrapperAnnotation";
}

- (NSString *)subtitle
{
    return [NSString stringWithFormat:@"%u", self.annotations.count];
}

- (BOOL)isCluster
{
    return self.annotations.count > 1;
}

@end
