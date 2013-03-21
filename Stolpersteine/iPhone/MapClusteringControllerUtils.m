//
//  MapClusteringControllerUtils.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 21.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringControllerUtils.h"

id<MKAnnotation> MapClusteringControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint)
{
    NSArray *sortedAnnotations = [annotations.allObjects sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
        
        CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, mapPoint);
        CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, mapPoint);
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return sortedAnnotations.count > 0 ? [sortedAnnotations objectAtIndex:0] : nil;
}