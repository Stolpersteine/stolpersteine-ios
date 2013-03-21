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

@end
