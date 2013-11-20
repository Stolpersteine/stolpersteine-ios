//
//  LocalizationTests.m
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

#import "MapClusterControllerUtilsTests.h"

#import "MapClusterControllerUtils.h"

@implementation MapClusterControllerUtilsTests

- (void)testFindClosestAnnotationNil
{
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(nil, mapPoint);
    XCTAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotationEmpty
{
    NSMutableSet *annotations = [[NSMutableSet alloc] init];
    MKMapPoint mapPoint = MKMapPointMake(0, 0);
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(annotations, mapPoint);
    XCTAssertNil(annotation, @"Wrong annotation");
}

- (void)testFindClosestAnnotation
{
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(45, 45);
    MKMapPoint mapPoint = MKMapPointForCoordinate(coordinate);

    NSMutableSet *annotations = [[NSMutableSet alloc] initWithCapacity:5];
    MKPointAnnotation *annotation0 = [[MKPointAnnotation alloc] init];
    annotation0.coordinate = CLLocationCoordinate2DMake(40, 40);
    [annotations addObject:annotation0];
    MKPointAnnotation *annotation1 = [[MKPointAnnotation alloc] init];
    annotation1.coordinate = CLLocationCoordinate2DMake(47, 47);
    [annotations addObject:annotation1];
    MKPointAnnotation *annotation2 = [[MKPointAnnotation alloc] init];
    annotation2.coordinate = CLLocationCoordinate2DMake(45.1, 44.9);
    [annotations addObject:annotation2];
    MKPointAnnotation *annotation3 = [[MKPointAnnotation alloc] init];
    annotation3.coordinate = CLLocationCoordinate2DMake(42.1, 43.7);
    [annotations addObject:annotation3];
    
    id<MKAnnotation> annotation = MapClusterControllerFindClosestAnnotation(annotations, mapPoint);
    XCTAssertEqualObjects(annotation, annotation2, @"Wrong annotation");
}

- (void)testAlignToCellSize
{
    MKMapRect mapRect = MKMapRectMake(0, 0, 15, 20);
    MKMapRect adjustedMapRect = MapClusterControllerAlignToCellSize(mapRect, 5);
    XCTAssertEqual(adjustedMapRect.origin.x, 0.0, @"Wrong origin x");
    XCTAssertEqual(adjustedMapRect.origin.y, 0.0, @"Wrong origin y");
    XCTAssertEqual(adjustedMapRect.size.width, 15.0, @"Wrong size width");
    XCTAssertEqual(adjustedMapRect.size.height, 20.0, @"Wrong size height");

    mapRect = MKMapRectMake(8, 8, 15, 20);
    adjustedMapRect = MapClusterControllerAlignToCellSize(mapRect, 6);
    XCTAssertEqual(adjustedMapRect.origin.x, 6.0, @"Wrong origin x");
    XCTAssertEqual(adjustedMapRect.origin.y, 6.0, @"Wrong origin y");
    XCTAssertEqual(adjustedMapRect.size.width, 18.0, @"Wrong size width");
    XCTAssertEqual(adjustedMapRect.size.height, 24.0, @"Wrong size height");
}

- (void)testCoordinateEqualToCoordinate
{
    CLLocationCoordinate2D coordinate0 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(MapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate0), @"Wrong coordinate");
    
    CLLocationCoordinate2D coordinate1 = CLLocationCoordinate2DMake(5.12, -0.72);
    XCTAssertTrue(MapClusterControllerCoordinateEqualToCoordinate(coordinate0, coordinate1), @"Wrong coordinate");

    CLLocationCoordinate2D coordinate2 = CLLocationCoordinate2DMake(5.12, -0.73);
    XCTAssertFalse(MapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate2), @"Wrong coordinate");

    CLLocationCoordinate2D coordinate3 = CLLocationCoordinate2DMake(5.11, -0.72);
    XCTAssertFalse(MapClusterControllerCoordinateEqualToCoordinate(coordinate1, coordinate3), @"Wrong coordinate");
}

@end
