//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringAnnotation.h"

#import "MapClusteringControllerDelegate.h"

@implementation MapClusteringAnnotation

- (NSString *)title
{
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(mapClusteringController:titleForClusterAnnotation:)]) {
        title = [self.delegate mapClusteringController:nil titleForClusterAnnotation:self];
    }
    
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle;
    if ([self.delegate respondsToSelector:@selector(mapClusteringController:subtitleForClusterAnnotation:)]) {
        subtitle = [self.delegate mapClusteringController:nil subtitleForClusterAnnotation:self];
    }

    return subtitle;
}

- (BOOL)isCluster
{
    return (self.annotations.count > 1);
}

@end
