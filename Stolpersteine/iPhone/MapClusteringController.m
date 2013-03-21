//
//  MapClusteringController.m
//  Stolpersteine
//
//  Created by Claus on 20.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringController.h"

#import "Stolperstein.h"
#import "StolpersteinAnnotation.h"
#import "StolpersteinClusterAnnotation.h"

@interface MapClusteringController()

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapView *allAnnotationsMapView;

@end

@implementation MapClusteringController

// This value controls the number of off screen annotations are displayed.
// A bigger number means more annotations, less chance of seeing annotations views pop in but
// decreased performance.
// A smaller number means fewer annotations, more chance of seeing annotations views pop in but
// better performance.
static double MARGIN_FACTOR = 0.5;

// Adjust this roughly based on the dimensions of your annotations views.
// Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance)
// Numbers too small result in overlapping annotations views and too many annotations in screen.
static double CELL_SIZE = 40.0; // [points] 

- (id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.allAnnotationsMapView = [[MKMapView alloc] initWithFrame:CGRectZero];
        return self;
    }
    return nil;
}

- (void)addStolpersteine:(NSArray *)stolpersteine
{
    NSMutableArray *stolpersteinAnnotations = [NSMutableArray arrayWithCapacity:stolpersteine.count];
    [stolpersteine enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        StolpersteinAnnotation *stolpersteinAnnotation = [[StolpersteinAnnotation alloc] initWithStolperstein:obj];
        [stolpersteinAnnotations addObject:stolpersteinAnnotation];
    }];
    [self.allAnnotationsMapView addAnnotations:stolpersteinAnnotations];
    [self updateVisibleAnnotations];
}

+ (id<MKAnnotation>)annotations:(NSSet *)annotations findClosestAnnotationWithDistanceToMapPoint:(MKMapPoint)mapPoint
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
    
    return [sortedAnnotations objectAtIndex:0];
}

- (id<MKAnnotation>)annotationInGrid:(MKMapRect)gridMapRect usingAnnotations:(NSSet *)annotations visibleAnnotations:(NSSet *)visibleAnnotations
{
    // First, see if one of the annotations we were already showing is in this mapRect
    NSSet *annotationsForGridSet = [annotations objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        BOOL returnValue = ([visibleAnnotations containsObject:obj]);
        if (returnValue) {
            *stop = YES;
        }
        return returnValue;
    }];
    
    if (annotationsForGridSet.count != 0) {
        return [annotationsForGridSet anyObject];
    }
    
    // Otherwise, sort the annotations based on their distance from the center of the grid square,
    // then choose the one closest to the center to show
    MKMapPoint centerMapPoint = MKMapPointMake(MKMapRectGetMidX(gridMapRect), MKMapRectGetMidY(gridMapRect));
    return [MapClusteringController annotations:annotations findClosestAnnotationWithDistanceToMapPoint:centerMapPoint];
}

+ (MKMapRect)mapView:(MKMapView *)mapView convertPointSize:(double)pointSize toMapRectFromView:(UIView *)view
{
    CLLocationCoordinate2D leftCoordinate = [mapView convertPoint:CGPointZero toCoordinateFromView:view];
    CLLocationCoordinate2D rightCoordinate = [mapView convertPoint:CGPointMake(pointSize, 0) toCoordinateFromView:view];
    double cellSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
    return MKMapRectMake(0, 0, cellSize, cellSize);
}

+ (MKMapRect)adjustMapRect:(MKMapRect)mapRect withMarginFactor:(double)marginFactor cellSize:(double)cellSize
{
    MKMapRect adjustedMapRect = MKMapRectInset(mapRect, -marginFactor * mapRect.size.width, -marginFactor * mapRect.size.height);
    double startX = floor(MKMapRectGetMinX(adjustedMapRect) / cellSize) * cellSize;
    double startY = floor(MKMapRectGetMinY(adjustedMapRect) / cellSize) * cellSize;
    double endX = floor(MKMapRectGetMaxX(adjustedMapRect) / cellSize) * cellSize;
    double endY = floor(MKMapRectGetMaxY(adjustedMapRect) / cellSize) * cellSize;
    return MKMapRectMake(startX, startY, endX - startX, endY - startY);
}

- (void)updateVisibleAnnotations
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    MKMapRect cellMapRect = [MapClusteringController mapView:self.mapView convertPointSize:CELL_SIZE toMapRectFromView:self.mapView.superview];
    MKMapRect gridMapRect = [MapClusteringController adjustMapRect:self.mapView.visibleMapRect withMarginFactor:MARGIN_FACTOR cellSize:MKMapRectGetWidth(cellMapRect)];
    
    // For each square in grid, pick one annotation to show
//    [self.mapView removeOverlays:self.mapView.overlays];
//    MKMapPoint points[4];
    cellMapRect.origin.y = MKMapRectGetMinY(gridMapRect);
    while (MKMapRectGetMinY(cellMapRect) < MKMapRectGetMaxY(gridMapRect)) {
        cellMapRect.origin.x = MKMapRectGetMinX(gridMapRect);
        
        while (MKMapRectGetMinX(cellMapRect) < MKMapRectGetMaxX(gridMapRect)) {
//            points[0] = MKMapPointMake(MKMapRectGetMinX(cellMapRect), MKMapRectGetMinY(cellMapRect));
//            points[1] = MKMapPointMake(MKMapRectGetMaxX(cellMapRect), MKMapRectGetMinY(cellMapRect));
//            points[2] = MKMapPointMake(MKMapRectGetMaxX(cellMapRect), MKMapRectGetMaxY(cellMapRect));
//            points[3] = MKMapPointMake(MKMapRectGetMinX(cellMapRect), MKMapRectGetMaxY(cellMapRect));
//            MKPolygon* poly = [MKPolygon polygonWithPoints:points count:4];
//            [self.mapView addOverlay:poly];

            NSMutableSet *allAnnotationsInBucket = [[self.allAnnotationsMapView annotationsInMapRect:cellMapRect] mutableCopy];
            if (allAnnotationsInBucket.count > 0) {
                NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:cellMapRect];
                
                StolpersteinAnnotation *annotationForGrid = (StolpersteinAnnotation *)[self annotationInGrid:cellMapRect usingAnnotations:allAnnotationsInBucket visibleAnnotations:visibleAnnotationsInBucket];
                [allAnnotationsInBucket removeObject:annotationForGrid];
                
                // Give the annotationForGrid a reference to all the annotations it will represent
                annotationForGrid.containedAnnotations = [allAnnotationsInBucket allObjects];
                [self.mapView addAnnotation:annotationForGrid];
                
                for (StolpersteinAnnotation *annotation in allAnnotationsInBucket) {
                    annotation.containedAnnotations = nil;
                    
                    // Remove annotations (with animation), which we've decided to cluster
                    if ([visibleAnnotationsInBucket containsObject:annotation]) {
                        CLLocationCoordinate2D actualCoordinate = annotation.coordinate;
                        [UIView animateWithDuration:0.3 animations:^{
                            annotation.coordinate = annotationForGrid.coordinate;
                        } completion:^(BOOL finished) {
                            annotation.coordinate = actualCoordinate;
                            [self.mapView removeAnnotation:annotation];
                        }];
                    }
                }
            }
            cellMapRect.origin.x += MKMapRectGetWidth(cellMapRect);
        }
        cellMapRect.origin.y += MKMapRectGetWidth(cellMapRect);
    }
    
    NSMutableSet *uniqueAnnotations = [[NSMutableSet alloc] initWithCapacity:self.mapView.annotations.count];
    NSUInteger numAnnotations = 0;
    for (id<MKAnnotation> annotation in self.mapView.annotations) {
        if ([annotation isKindOfClass:StolpersteinAnnotation.class]) {
            if ([uniqueAnnotations containsObject:annotation]) {
                NSLog(@"");
            }
            [uniqueAnnotations addObject:annotation];
            numAnnotations++;
            StolpersteinAnnotation *stolpersteinAnnotation = (StolpersteinAnnotation *)annotation;
            for (StolpersteinAnnotation *containedAnnotation in stolpersteinAnnotation.containedAnnotations) {
                if ([uniqueAnnotations containsObject:containedAnnotation]) {
                    NSLog(@"");
                }
                [uniqueAnnotations addObject:containedAnnotation];
                numAnnotations++;
            }
        }
    }

    NSTimeInterval duration = [NSDate timeIntervalSinceReferenceDate] - start;
    NSLog(@"duration = %f, mapAnnotations = %u, numAnnotations = %u, unique = %u", duration * 1000, self.mapView.annotations.count, numAnnotations, uniqueAnnotations.count);
}

@end
