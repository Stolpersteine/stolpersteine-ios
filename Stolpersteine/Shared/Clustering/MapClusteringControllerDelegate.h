//
//  MapClusteringControllerDelegate.h
//  Stolpersteine
//
//  Created by Claus on 28.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MapClusteringController;
@class MapClusteringAnnotation;

@protocol MapClusteringControllerDelegate <NSObject>

@optional
- (NSString *)mapClusteringController:(MapClusteringController *)mapClusteringController titleForClusterAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation;
- (NSString *)mapClusteringController:(MapClusteringController *)mapClusteringController subtitleForClusterAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation;

@end
