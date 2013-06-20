//
//  StolpersteinSyncControllerDelegate.h
//  Stolpersteine
//
//  Created by Claus on 20.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StolpersteinSyncController;

@protocol StolpersteinSyncControllerDelegate <NSObject>

@optional
- (void)stolpersteinSyncController:(StolpersteinSyncController *)stolpersteinSyncController didAddStolpersteine:(NSArray *)stolpersteine;
- (void)stolpersteinSyncController:(StolpersteinSyncController *)stolpersteinSyncController didRemoveStolpersteine:(NSArray *)stolpersteine;

@end
