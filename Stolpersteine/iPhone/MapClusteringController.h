//
//  MapClusteringController.h
//  Stolpersteine
//
//  Created by Claus on 20.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapClusteringController : NSObject

@property (strong, nonatomic) MKMapView *mapView;
@property (strong, nonatomic) MKMapView *allAnnotationsMapView;

- (id)initWithMapView:(MKMapView *)aMapView;
- (void)addStolpersteine:(NSArray *)stolpersteine;
- (void)updateVisibleAnnotations;

@end
