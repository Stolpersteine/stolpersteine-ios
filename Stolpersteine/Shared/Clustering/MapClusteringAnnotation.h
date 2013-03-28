//
//  StolpersteinWrapperAnnotation.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapClusteringAnnotation : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) NSArray *annotations;
@property (nonatomic, assign, readonly, getter = isCluster) BOOL cluster;

@end
