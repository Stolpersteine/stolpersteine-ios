//
//  MapClusterControllerUtils.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 21.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class MapClusterAnnotation;

id<MKAnnotation> MapClusterControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint);
MKMapRect MapClusterControllerAlignToCellSize(MKMapRect mapRect, double cellSize);
MapClusterAnnotation *MapClusterControllerFindAnnotation(MKMapRect cellMapRect, NSSet *annotations, NSSet *visibleAnnotations);