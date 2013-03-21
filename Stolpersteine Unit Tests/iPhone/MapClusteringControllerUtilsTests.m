//
//  LocalizationTests.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringControllerUtilsTests.h"

#import "MapClusteringControllerUtils.h"
#import "StolpersteinAnnotation.h"
#import "Stolperstein.h"

@implementation MapClusteringControllerUtilsTests

- (void)testFindClosestAnnotationNil
{
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusteringControllerFindClosestAnnotation(nil, mapPoint);
    STAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotationEmpty
{
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusteringControllerFindClosestAnnotation(annotations, mapPoint);
    STAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45, 45);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);

    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:5];
    StolpersteinAnnotation *annotation0 = [[StolpersteinAnnotation alloc] initWithStolperstein:[[Stolperstein alloc] init]];
    annotation0.coordinate = CLLocationCoordinate2DMake(40, 40);
    [annotations addObject:annotation0];
    StolpersteinAnnotation *annotation1 = [[StolpersteinAnnotation alloc] initWithStolperstein:[[Stolperstein alloc] init]];
    annotation1.coordinate = CLLocationCoordinate2DMake(47, 47);
    [annotations addObject:annotation1];
    StolpersteinAnnotation *annotation2 = [[StolpersteinAnnotation alloc] initWithStolperstein:[[Stolperstein alloc] init]];
    annotation2.coordinate = CLLocationCoordinate2DMake(45.1, 44.9);
    [annotations addObject:annotation2];
    StolpersteinAnnotation *annotation3 = [[StolpersteinAnnotation alloc] initWithStolperstein:[[Stolperstein alloc] init]];
    annotation3.coordinate = CLLocationCoordinate2DMake(42.1, 43.7);
    [annotations addObject:annotation3];
    
    id<MKAnnotation> annotation = MapClusteringControllerFindClosestAnnotation(annotations, mapPoint);
    STAssertEqualObjects(annotation, annotation2, @"Wrong annotation");
}

- (void)testAdjustMapRectNoMargin
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 15, 15);
    MKMapRect adjustedMapRect = MapClusteringControllerAdjustMapRect(mapRect, 0, 5);
    STAssertEquals(adjustedMapRect.origin.x, 0.0, @"Wrong origin x");
    STAssertEquals(adjustedMapRect.origin.y, 0.0, @"Wrong origin y");
    STAssertEquals(adjustedMapRect.size.width, 15.0, @"Wrong size width");
    STAssertEquals(adjustedMapRect.size.height, 15.0, @"Wrong size height");

    mapRect = MKMapRectMake(8, 8, 15, 15);
    adjustedMapRect = MapClusteringControllerAdjustMapRect(mapRect, 0, 6);
    STAssertEquals(adjustedMapRect.origin.x, 6.0, @"Wrong origin x");
    STAssertEquals(adjustedMapRect.origin.y, 6.0, @"Wrong origin y");
    STAssertEquals(adjustedMapRect.size.width, 18.0, @"Wrong size width");
    STAssertEquals(adjustedMapRect.size.height, 18.0, @"Wrong size height");
}

//- (void)testAdjustMapRectMargin
//{
//    MKMapRect mapRect = MKMapRectMake(7.5, 7.5, 7.5, 7.5);
//    MKMapRect adjustedMapRect = MapClusteringControllerAdjustMapRect(mapRect, 1, 5);
//    STAssertEquals(adjustedMapRect.origin.x, 0.0, @"Wrong origin x");
//    STAssertEquals(adjustedMapRect.origin.y, 0.0, @"Wrong origin y");
//    STAssertEquals(adjustedMapRect.size.width, 15.0, @"Wrong size width");
//    STAssertEquals(adjustedMapRect.size.height, 15.0, @"Wrong size height");
//    
//    mapRect = MKMapRectMake(8, 8, 15, 15);
//    adjustedMapRect = MapClusteringControllerAdjustMapRect(mapRect, 0, 6);
//    STAssertEquals(adjustedMapRect.origin.x, 6.0, @"Wrong origin x");
//    STAssertEquals(adjustedMapRect.origin.y, 6.0, @"Wrong origin y");
//    STAssertEquals(adjustedMapRect.size.width, 18.0, @"Wrong size width");
//    STAssertEquals(adjustedMapRect.size.height, 18.0, @"Wrong size height");
//}

@end
