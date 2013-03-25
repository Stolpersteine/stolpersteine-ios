//
//  MapClusteringControllerUtils.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 21.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class MapClusteringAnnotation;

id<MKAnnotation> MapClusteringControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint);
MKMapRect MapClusteringControllerAlignToCellSize(MKMapRect mapRect, double cellSize);
MapClusteringAnnotation *MapClusteringControllerFindAnnotation(MKMapRect cellMapRect, NSSet *annotations, NSSet *visibleAnnotations);