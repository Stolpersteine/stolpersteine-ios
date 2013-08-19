//
//  MapClusterController.m
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

// Based on https://github.com/MarcoSero/MSMapClustering by MarcoSero

#import "MapClusterController.h"

#import "MapClusterControllerUtils.h"
#import "MapClusterAnnotation.h"
#import "MapClusterControllerDelegate.h"

@interface MapClusterController()

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapView *allAnnotationsMapView;

@end

@implementation MapClusterController

// This value controls the number of off screen annotations are displayed.
// A bigger number means more annotations, less chance of seeing annotations views pop in but
// decreased performance.
// A smaller number means fewer annotations, more chance of seeing annotations views pop in but
// better performance.
static double MARGIN_FACTOR = 0.5;  // [width/height]

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
    }
    return self;
}

- (void)addAnnotations:(NSArray *)annotations
{
    [self.allAnnotationsMapView addAnnotations:annotations];
    [self updateAnnotationsAnimated:YES completion:NULL];
}

- (NSUInteger)numberOfAnnotations
{
    return self.allAnnotationsMapView.annotations.count;
}

- (double)convertPointSize:(double)pointSize toMapPointSizeFromView:(UIView *)view
{
    CLLocationCoordinate2D leftCoordinate = [self.mapView convertPoint:CGPointZero toCoordinateFromView:view];
    CLLocationCoordinate2D rightCoordinate = [self.mapView convertPoint:CGPointMake(pointSize, 0) toCoordinateFromView:view];
    double cellSize = MKMapPointForCoordinate(rightCoordinate).x - MKMapPointForCoordinate(leftCoordinate).x;
    return cellSize;
}

- (void)updateAnnotationsAnimated:(BOOL)animated completion:(void (^)())completion
{
    double cellSize = [self convertPointSize:CELL_SIZE toMapPointSizeFromView:self.mapView.superview];

    // Expand map rect and align to cell size to avoid popping when panning
    MKMapRect visibleMapRect = self.mapView.visibleMapRect;
    MKMapRect gridMapRect = MKMapRectInset(visibleMapRect, -MARGIN_FACTOR * visibleMapRect.size.width, -MARGIN_FACTOR * visibleMapRect.size.height);
    gridMapRect = MapClusterControllerAlignToCellSize(gridMapRect, cellSize);
    MKMapRect cellMapRect = MKMapRectMake(0, MKMapRectGetMinY(gridMapRect), cellSize, cellSize);

    // For each cell in the grid, pick one annotation to show
    while (MKMapRectGetMinY(cellMapRect) < MKMapRectGetMaxY(gridMapRect)) {
        cellMapRect.origin.x = MKMapRectGetMinX(gridMapRect);
        
        while (MKMapRectGetMinX(cellMapRect) < MKMapRectGetMaxX(gridMapRect)) {
            NSMutableSet *allAnnotationsInCell = [[self.allAnnotationsMapView annotationsInMapRect:cellMapRect] mutableCopy];
            if (allAnnotationsInCell.count > 0) {
                NSMutableSet *visibleAnnotationsInCell = [self.mapView annotationsInMapRect:cellMapRect].mutableCopy;
                MKUserLocation *userLocation = self.mapView.userLocation;
                if (userLocation) {
                    [visibleAnnotationsInCell removeObject:userLocation];
                }
                
                MapClusterAnnotation *annotationForCell = MapClusterControllerFindAnnotation(cellMapRect, allAnnotationsInCell, visibleAnnotationsInCell);
                annotationForCell.annotations = allAnnotationsInCell.allObjects;
                annotationForCell.delegate = self.delegate;
                
                [visibleAnnotationsInCell removeObject:annotationForCell];
                [self.mapView removeAnnotations:visibleAnnotationsInCell.allObjects];
                [self.mapView removeAnnotation:annotationForCell];  // trigger mapView:viewForAnnotation:
                [self.mapView addAnnotation:annotationForCell];
            }
            cellMapRect.origin.x += MKMapRectGetWidth(cellMapRect);
        }
        cellMapRect.origin.y += MKMapRectGetWidth(cellMapRect);
    }
    
    if (completion) {
        completion();
    }
}

@end
