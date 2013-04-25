//
//  MapClusterControllerDelegate.h
//  Stolpersteine
//
//  Created by Claus on 28.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MapClusterController;
@class MapClusterAnnotation;

@protocol MapClusterControllerDelegate <NSObject>

@optional
- (NSString *)mapClusterController:(MapClusterController *)mapClusterController titleForClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation;
- (NSString *)mapClusterController:(MapClusterController *)mapClusterController subtitleForClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation;

@end
