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

- (void)createStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        for (Stolperstein *stolperstein in stolpersteine) {
            [transaction setObject:stolperstein forKey:stolperstein.ID inCollection:StolpersteineReadDataServiceCollection];
        }
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

- (void)deleteStolpersteine:(NSArray *)stolpersteine completionHandler:(void (^)())completionHandler
{
    [self readWriteWithBlock:^(YapDatabaseReadWriteTransaction *transaction) {
        NSArray *keys = [stolpersteine valueForKey:NSStringFromSelector(@selector(ID))];
        [transaction removeObjectsForKeys:keys inCollection:StolpersteineReadDataServiceCollection];
    } completionBlock:^{
        if (completionHandler) {
            completionHandler();
        }
    }];
}

@end
