//
//  StolpersteinWrapperAnnotation.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapClusteringControllerDelegate;

@interface MapClusteringAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, weak) id<MapClusteringControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, assign, readonly, getter = isCluster) BOOL cluster;

@end
