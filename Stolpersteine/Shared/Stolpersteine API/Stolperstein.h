//
//  Stolperstein.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 08.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface Stolperstein : NSObject

@property (nonatomic, strong) NSString *personFirstName;
@property (nonatomic, strong) NSString *personLastName;
@property (nonatomic, strong) NSString *locationStreet;
@property (nonatomic, strong) NSString *locationZipCode;
@property (nonatomic, strong) NSString *locationCity;
@property (nonatomic, assign) CLLocationCoordinate2D locationCoordinates;

@end
