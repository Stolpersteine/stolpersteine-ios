//
//  Stolperstein.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface Stolperstein : NSObject<MKAnnotation>

@property (nonatomic, strong) NSString *id;
@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) NSString *personFirstName;
@property (nonatomic, strong) NSString *personLastName;
@property (nonatomic, strong) NSString *personBiographyURLString;
@property (nonatomic, strong) NSString *sourceURLString;
@property (nonatomic, strong) NSString *sourceName;
@property (nonatomic, strong) NSDate *sourceRetrievedAt;
@property (nonatomic, strong) NSString *locationStreet;
@property (nonatomic, strong) NSString *locationZipCode;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinate;

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *subtitle;
@property (nonatomic, readonly, assign) CLLocationCoordinate2D coordinate;

@end
