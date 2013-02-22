//
//  Stolperstein.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface Stolperstein : NSObject<MKAnnotation>

// Original data
@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *imageURLString;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *personFirstName;
@property (nonatomic, strong) NSString *personLastName;
@property (nonatomic, strong) NSString *sourceURLString;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSDate *sourceRetrievedAt;
@property (nonatomic, strong) NSString *locationStreet;
@property (nonatomic, readonly) NSString *locationStreetName;
@property (nonatomic, strong) NSString *locationZipCode;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, strong) CLLocation *locationCoordinates;

// MKAnnotation properties
@property (nonatomic, readonly, copy) NSString *title;
@property (nonatomic, readonly, copy) NSString *subtitle;
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

// Clustering
@property (nonatomic, strong) Stolperstein *clusterAnnotation;
@property (nonatomic, strong) NSArray *containedAnnotations;

@end
