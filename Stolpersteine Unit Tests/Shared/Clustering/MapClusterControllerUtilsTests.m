//
//  LocalizationTests.m
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusterControllerUtilsTests.h"

#import "MapClusterControllerUtils.h"
#import "Stolperstein.h"

@implementation MapClusterControllerUtilsTests

- (void)testFindClosestAnnotationNil
{
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(nil, mapPoint);
    STAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotationEmpty
{
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(annotations, mapPoint);
    STAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45, 45);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);

    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:5];
    Stolperstein *stolperstein0 = [[Stolperstein alloc] init];
    stolperstein0.locationCoordinate = CLLocationCoordinate2DMake(40, 40);
    [annotations addObject:stolperstein0];
    Stolperstein *stolperstein1 = [[Stolperstein alloc] init];
    stolperstein1.locationCoordinate = CLLocationCoordinate2DMake(47, 47);
    [annotations addObject:stolperstein1];
    Stolperstein *stolperstein2 = [[Stolperstein alloc] init];
    stolperstein2.locationCoordinate = CLLocationCoordinate2DMake(45.1, 44.9);
    [annotations addObject:stolperstein2];
    Stolperstein *stolperstein3 = [[Stolperstein alloc] init];
    stolperstein3.locationCoordinate = CLLocationCoordinate2DMake(42.1, 43.7);
    [annotations addObject:stolperstein3];
    
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(annotations, mapPoint);
    STAssertEqualObjects(annotation, stolperstein2, @"Wrong annotation");
}

- (void)testAlign
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 15, 20);
    MKMapRect adjustedMapRect = MapClusterControllerAlignToCellSize(mapRect, 5);
    STAssertEquals(adjustedMapRect.origin.x, 0.0, @"Wrong origin x");
    STAssertEquals(adjustedMapRect.origin.y, 0.0, @"Wrong origin y");
    STAssertEquals(adjustedMapRect.size.width, 15.0, @"Wrong size width");
    STAssertEquals(adjustedMapRect.size.height, 20.0, @"Wrong size height");

    mapRect = MKMapRectMake(8, 8, 15, 20);
    adjustedMapRect = MapClusterControllerAlignToCellSize(mapRect, 6);
    STAssertEquals(adjustedMapRect.origin.x, 6.0, @"Wrong origin x");
    STAssertEquals(adjustedMapRect.origin.y, 6.0, @"Wrong origin y");
    STAssertEquals(adjustedMapRect.size.width, 18.0, @"Wrong size width");
    STAssertEquals(adjustedMapRect.size.height, 24.0, @"Wrong size height");
}

@end
