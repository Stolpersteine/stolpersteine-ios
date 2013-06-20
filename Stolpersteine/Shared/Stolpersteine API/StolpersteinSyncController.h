//
//  StolpersteinSyncController.h
//  Stolpersteine
//
//  Created by Claus on 20.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StolpersteinNetworkService;
@protocol StolpersteinSyncControllerDelegate;

@interface StolpersteinSyncController : NSObject

@property (nonatomic, strong, readonly) StolpersteinNetworkService *networkService;
@property (nonatomic, weak) id<StolpersteinSyncControllerDelegate> delegate;

- (id)initWithNetworkService:(StolpersteinNetworkService *)networkService;
- (void)syncStolpersteine;

@end
