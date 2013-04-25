//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusterAnnotation.h"

#import "MapClusterControllerDelegate.h"

@implementation MapClusterAnnotation

- (NSString *)title
{
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(mapClusterController:titleForClusterAnnotation:)]) {
        title = [self.delegate mapClusterController:nil titleForClusterAnnotation:self];
    }
    
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle;
    if ([self.delegate respondsToSelector:@selector(mapClusterController:subtitleForClusterAnnotation:)]) {
        subtitle = [self.delegate mapClusterController:nil subtitleForClusterAnnotation:self];
    }

    return subtitle;
}

- (BOOL)isCluster
{
    return (self.annotations.count > 1);
}

@end
