//
//  MapClusteringController.h
//  Stolpersteine
//
//  Created by Claus on 20.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapClusteringControllerDelegate;

@interface MapClusteringController : NSObject

@property (nonatomic, weak) id<MapClusteringControllerDelegate> delegate;

- (id)initWithMapView:(MKMapView *)mapView;
- (void)addAnnotations:(NSArray *)annotations;
- (void)updateAnnotationsAnimated:(BOOL)animated completion:(void (^)())completion;

@end
