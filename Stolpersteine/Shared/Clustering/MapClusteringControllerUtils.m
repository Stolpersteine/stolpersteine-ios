//
//  MapClusteringControllerUtils.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 21.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringControllerUtils.h"

#import "MapClusteringAnnotation.h"

id<MKAnnotation> MapClusteringControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint)
{
    id<MKAnnotation> closestAnnotation;
    CLLocationDistance closestDistance = DBL_MAX;
    for (id<MKAnnotation> annotation in annotations) {
        MKMapPoint annotationAsMapPoint = MKMapPointForCoordinate(annotation.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint, annotationAsMapPoint);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestAnnotation = annotation;
        }
    }
    
    return closestAnnotation;
}

MKMapRect MapClusteringControllerAlignToCellSize(MKMapRect mapRect, double cellSize)
{
    NSCAssert(mapRect.origin.x >= 0, @"Invalid origin");
    NSCAssert(mapRect.origin.y >= 0, @"Invalid origin");
    NSCAssert(cellSize != 0, @"Invalid cell size");
    
    double startX = floor(MKMapRectGetMinX(mapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(mapRect) / cellSize) * cellSize;
    double endX = ceil(MKMapRectGetMaxX(mapRect) / cellSize) * cellSize;
    double endY = ceil(MKMapRectGetMaxY(mapRect) / cellSize) * cellSize;
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}

MapClusteringAnnotation *MapClusteringControllerFindAnnotation(MKMapRect cellMapRect, NSSet *annotations, NSSet *visibleAnnotations)
{
    // See if there's already a visible annotation in this cell
    for (id<MKAnnotation> annotation in annotations) {
        for (MapClusteringAnnotation *visibleAnnotation in visibleAnnotations) {
            if ([visibleAnnotation.stolpersteine containsObject:annotation]) {
                return visibleAnnotation;
            }
        }
    }
    
    // Otherwise, choose the closest annotation to the center
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(cellMapRect), MKMapRectGetMidY(cellMapRect));
    id<MKAnnotation> closestAnnotation = MapClusteringControllerFindClosestAnnotation(annotations, centerMapPoint);
    MapClusteringAnnotation *annotation = [[MapClusteringAnnotation alloc] init];
    annotation.coordinate = closestAnnotation.coordinate;
    
    return annotation;
}