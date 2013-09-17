//
//  MapClusterMapViewDelegateProxy.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 17.09.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapClusterMapViewDelegateProxy : NSObject<MKMapViewDelegate>

@property (nonatomic, weak, readonly) NSObject<MKMapViewDelegate> *target;
@property (nonatomic, weak) NSObject<MKMapViewDelegate> *delegate;

- (id)initWithMapView:(MKMapView *)mapView;

@end
