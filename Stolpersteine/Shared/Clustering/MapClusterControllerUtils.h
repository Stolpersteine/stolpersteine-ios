//
//  MapClusterControllerUtils.h
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

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class MapClusterAnnotation;

id<MKAnnotation> MapClusterControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint);
MKMapRect MapClusterControllerAlignToCellSize(MKMapRect mapRect, double cellSize);
MapClusterAnnotation *MapClusterControllerFindAnnotation(MKMapRect cellMapRect, NSSet *annotations, NSSet *visibleAnnotations);
double MapClusterControllerMapLengthForLength(MKMapView *mapView, UIView *view, double length);
BOOL MapClusterControllerCoordinateEqualToCoordinate(CLLocationCoordinate2D coordinate1, CLLocationCoordinate2D coordinate2);
MapClusterAnnotation *MapClusterControllerClusterAnnotationForAnnotation(MKMapView *mapView, id<MKAnnotation> annotation, MKMapRect mapRect);