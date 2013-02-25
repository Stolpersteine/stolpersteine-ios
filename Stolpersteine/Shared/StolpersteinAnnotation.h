//
//  StolpersteinAnnotation.h
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class Stolperstein;

@interface StolpersteinAnnotation : NSObject<MKAnnotation>

@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@property (nonatomic, strong) Stolperstein *stolperstein;

@property (nonatomic, strong) StolpersteinAnnotation *clusterAnnotation;
@property (nonatomic, strong) NSArray *containedAnnotations;

- (id)initWithStolperstein:(Stolperstein *)stolperstein;

@end
