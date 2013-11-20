//
//  MapClusterControllerUtils.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MapClusterControllerUtils.h"

#import "MapClusterAnnotation.h"

#define fequal(a, b) (fabs((a) - (b)) < FLT_EPSILON)

id<MKAnnotation> MapClusterControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint)
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

MKMapRect MapClusterControllerAlignToCellSize(MKMapRect mapRect, double cellSize)
{
//    NSCAssert(cellSize != 0, @"Invalid cell size");
    
    double startX = floor(MKMapRectGetMinX(mapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(mapRect) / cellSize) * cellSize;
    double endX = ceil(MKMapRectGetMaxX(mapRect) / cellSize) * cellSize;
    double endY = ceil(MKMapRectGetMaxY(mapRect) / cellSize) * cellSize;
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}

MapClusterAnnotation *MapClusterControllerFindAnnotation(MKMapRect cellMapRect, NSSet *annotations, NSSet *visibleAnnotations)
{
    // See if there's already a visible annotation in this cell
    for (id<MKAnnotation> annotation in annotations) {
        for (MapClusterAnnotation *visibleAnnotation in visibleAnnotations) {
            if ([visibleAnnotation.annotations containsObject:annotation]) {
                return visibleAnnotation;
            }
        }
    }
    
    // Otherwise, choose the closest annotation to the center
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(cellMapRect), MKMapRectGetMidY(cellMapRect));
    id<MKAnnotation> closestAnnotation = MapClusterControllerFindClosestAnnotation(annotations, centerMapPoint);
    MapClusterAnnotation *annotation = [[MapClusterAnnotation alloc] init];
    annotation.coordinate = closestAnnotation.coordinate;
    
    return annotation;
}

double MapClusterControllerMapLengthForLength(MKMapView *mapView, UIView *view, double length)
{
    // Convert points to coordinates
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:CGPointZero toCoordinateFromView:view];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:CGPointMake(length, 0) toCoordinateFromView:view];
    
    // Convert coordinates to map points
    MKMapPoint leftMapPoint = MKMapPointForCoordinate(leftCoordinate);
    MKMapPoint rightMapPoint = MKMapPointForCoordinate(rightCoordinate);
    
    // Calculate distance between map points
    double xd = leftMapPoint.x - rightMapPoint.x;
    double yd = leftMapPoint.y - rightMapPoint.y;
    double mapLength = sqrt(xd*xd + yd*yd);
    
    return mapLength;
}

BOOL MapClusterControllerCoordinateEqualToCoordinate(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2)
{
    BOOL isCoordinateUpToDate = fequal(coordinate1.latitude, coordinate2.latitude) && fequal(coordinate1.longitude, coordinate2.longitude);
    return isCoordinateUpToDate;
}

MapClusterAnnotation *MapClusterControllerClusterAnnotationForAnnotation(MKMapView *mapView, id<MKAnnotation> annotation, MKMapRect mapRect)
{
    MapClusterAnnotation *annotationResult;
    
    NSSet *mapAnnotations = [mapView annotationsInMapRect:mapRect];
    for (id<MKAnnotation> mapAnnotation in mapAnnotations) {
        if ([mapAnnotation isKindOfClass:MapClusterAnnotation.class]) {
            MapClusterAnnotation *mapClusterAnnotation = (MapClusterAnnotation *)mapAnnotation;
            NSUInteger index = [mapClusterAnnotation.annotations indexOfObject:annotation];
            if (index != NSNotFound) {
                annotationResult = mapClusterAnnotation;
                break;
            }
        }
    }
    
    return annotationResult;
}