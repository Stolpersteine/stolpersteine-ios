//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringAnnotation.h"

@implementation MapClusteringAnnotation

- (BOOL)isCluster
{
    return (self.annotations.count > 1);
}

@end
