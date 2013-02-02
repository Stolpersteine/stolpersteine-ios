//
//  StolpersteineGroup.h
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface StolpersteinGroup : NSObject<MKAnnotation>

// Original data
@property (strong, nonatomic) NSArray *stolpersteine;
@property (nonatomic, strong) CLLocation *locationCoordinates;

// MKAnnotation properties
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end
