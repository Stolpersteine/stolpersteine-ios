//
//  StolpersteineReadWriteDataService.m
//  Stolpersteine
//
//  Created by Hoefele, Claus on 28.03.14.
//  Copyright (c) 2014 Option-U Software. All rights reserved.
//

#import "StolpersteineReadWriteDataService.h"

#import "YapDatabase.h"
#import "Stolperstein.h"

NSString * const StolpersteineReadWriteDataServiceAddedIDsKey = @"added";
NSString * const StolpersteineReadWriteDataServiceUpdatedIDsKey = @"updated";
NSString * const StolpersteineReadWriteDataServiceRemovedIDsKey = @"removed";

@implementation StolpersteineReadWriteDataService

- (void)readWriteWithBlock:(void (^)(YapDatabaseReadWriteTransaction *transaction))block completionBlock:(dispatch_block_t)completionBlock
{
    if (self.isSynchronous) {
        [self.connection readWriteWithBlock:block];
        if (completionBlock) {
            completionBlock();
        }
    } else {
        [self.connection asyncReadWriteWithBlock:block completionBlock:completionBlock];
    }
}

- (void)createOrUpdateStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSMutableArray *addedIDs = [NSMutableArray array];
        NSMutableArray *updatedIDs = [NSMutableArray array];
        for (Stolperstein *stolperstein in stolpersteine) {
            Stolperstein *existingStolperstein = [transaction objectForKey:stolperstein.ID inCollection:StolpersteineReadDataServiceCollection];
            if (![existingStolperstein isEqualToStolperstein:stolperstein]) {
                
                if (existingStolperstein) {
                    [updatedIDs addObject:stolperstein.ID];
                } else {
                    [addedIDs addObject:stolperstein.ID];
                }
                
                [transaction setObject:stolperstein forKey:stolperstein.ID inCollection:StolpersteineReadDataServiceCollection];
            }
        }
        [transaction setCustomObjectForYapDatabaseModifiedNotification:@{StolpersteineReadWriteDataServiceAddedIDsKey : addedIDs, StolpersteineReadWriteDataServiceUpdatedIDsKey : updatedIDs}];
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)deleteStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSArray *removedIDs = [stolpersteine valueForKey:NSStringFromSelector(@selector(ID))];
        [transaction removeObjectsForKeys:removedIDs inCollection:StolpersteineReadDataServiceCollection];
        [transaction setCustomObjectForYapDatabaseModifiedNotification:@{StolpersteineReadWriteDataServiceRemovedIDsKey : removedIDs}];
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end
