//
//  StolpersteineReadWriteDataService.h
//  Stolpersteine
//
//  Created by Hoefele, Claus on 28.03.14.
//  Copyright (c) 2014 Option-U Software. All rights reserved.
//

#import "StolpersteineReadDataService.h"

@interface StolpersteineReadWriteDataService : StolpersteineReadDataService

extern NSString * const StolpersteineReadWriteDataServiceAddedIDsKey;
extern NSString * const StolpersteineReadWriteDataServiceUpdatedIDsKey;
extern NSString * const StolpersteineReadWriteDataServiceRemovedIDsKey;

- (void)createOrUpdateStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler;
- (void)deleteStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler;

@end
