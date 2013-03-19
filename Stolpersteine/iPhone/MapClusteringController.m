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
static float marginFactor = 0.5;

// Adjust this roughly based on the dimensions of your annotations views.
// Bigger numbers more aggressively coalesce annotations (fewer annotations displayed but better performance)
// Numbers too small result in overlapping annotations views and too many annotations in screen.
static float bucketSize = 40.0;

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
    NSArray *sortedAnnotations = [[annotations allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        MKMapPoint mapPoint1 = MKMapPointForCoordinate(((id<MKAnnotation>)obj1).coordinate);
        MKMapPoint mapPoint2 = MKMapPointForCoordinate(((id<MKAnnotation>)obj2).coordinate);
        
        CLLocationDistance distance1 = MKMetersBetweenMapPoints(mapPoint1, centerMapPoint);
        CLLocationDistance distance2 = MKMetersBetweenMapPoints(mapPoint2, centerMapPoint);
        
        if (distance1 < distance2) {
            return NSOrderedAscending;
        } else {
            return NSOrderedDescending;
        }
    }];
    
    return [sortedAnnotations objectAtIndex:0];
}

- (void)updateVisibleAnnotations
{
    NSTimeInterval start = [NSDate timeIntervalSinceReferenceDate];
    
    // fix performance and visual clutter by calling update when change map region
    // it's called any time region changed on the map
    
    // Find all the annotation in the visible area + a wide margin to avoid popping annotation
    // views in and out while panning the map
    MKMapRect visibleMapRect = [self.mapView visibleMapRect];
    MKMapRect adjustedVisibleMapRect = MKMapRectInset(visibleMapRect, -marginFactor * visibleMapRect.size.width, -marginFactor * visibleMapRect.size.height);
    
    // Determine how wide each bucket will be, as a MapRect square
    CLLocationCoordinate2D leftCoordinate = [self.mapView convertPoint:CGPointZero toCoordinateFromView:[self.mapView superview]];
    CLLocationCoordinate2D rightCoordinate = [self.mapView convertPoint:CGPointMake(bucketSize, 0) toCoordinateFromView:[self.mapView superview]];
    double gridSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
    MKMapRect gridMapRect = MKMapRectMake(0, 0, gridSize, gridSize);
    
    // Condense annotations with a padding of two squares, around the visibleMapRect
    double startX = floor(MKMapRectGetMinX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double startY = floor(MKMapRectGetMinY(adjustedVisibleMapRect) / gridSize) * gridSize;
    double endX = floor(MKMapRectGetMaxX(adjustedVisibleMapRect) / gridSize) * gridSize;
    double endY = floor(MKMapRectGetMaxY(adjustedVisibleMapRect) / gridSize) * gridSize;
    
    // For each square in grid, pick one annotation to show
    gridMapRect.origin.y = startY;
    while (MKMapRectGetMinY(gridMapRect) < endY) {
        gridMapRect.origin.x = startX;
        
        while (MKMapRectGetMinX(gridMapRect) < endX) {
            NSMutableSet *allAnnotationsInBucket = [[self.allAnnotationsMapView annotationsInMapRect:gridMapRect] mutableCopy];
            if (allAnnotationsInBucket.count > 0) {
                NSSet *visibleAnnotationsInBucket = [self.mapView annotationsInMapRect:gridMapRect];
                
                StolpersteinAnnotation *annotationForGrid = (StolpersteinAnnotation *)[self annotationInGrid:gridMapRect usingAnnotations:allAnnotationsInBucket visibleAnnotations:visibleAnnotationsInBucket];
                [allAnnotationsInBucket removeObject:annotationForGrid];
                
                // Give the annotationForGrid a reference to all the annotation it will represent
                annotationForGrid.containedAnnotations = [allAnnotationsInBucket allObjects];
                [self.mapView addAnnotation:annotationForGrid];
                
                for (StolpersteinAnnotation *annotation in allAnnotationsInBucket) {
                    annotation.containedAnnotations = nil;
                    
                    // Remove annotations (with animation) which we've decided to cluster
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
            gridMapRect.origin.x += gridSize;
        }
        gridMapRect.origin.y += gridSize;
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
