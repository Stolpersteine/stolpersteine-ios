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

- (id)initWithMapView:(MKMapView *)mapView;
- (void)addStolpersteine:(NSArray *)stolpersteine;
- (void)updateAnnotationsAnimated:(BOOL)animated completion:(void (^)())completion;

@end
