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

MKMapRect MapClusteringControllerAdjustMapRect(MKMapRect mapRect, double marginFactor, double cellSize)
{
    NSCAssert(mapRect.origin.x >= 0, @"Invalid origin");
    NSCAssert(mapRect.origin.y >= 0, @"Invalid origin");
    NSCAssert(cellSize != 0, @"Invalid cell size");
    
    // Expand map rect
    MKMapRect adjustedMapRect = MKMapRectInset(mapRect, -marginFactor * mapRect.size.width, -marginFactor * mapRect.size.height);
    
    // Align to grid based on cell size. Includes padding if necessary.
    double startX = floor(MKMapRectGetMinX(adjustedMapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(adjustedMapRect) / cellSize) * cellSize;
    double endX = ceil(MKMapRectGetMaxX(adjustedMapRect) / cellSize) * cellSize;
    double endY = ceil(MKMapRectGetMaxY(adjustedMapRect) / cellSize) * cellSize;
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}
