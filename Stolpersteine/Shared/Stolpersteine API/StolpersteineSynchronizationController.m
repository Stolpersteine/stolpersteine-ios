//
//  StolpersteineSynchronizationController.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "StolpersteineSynchronizationController.h"

#import "StolpersteineNetworkService.h"
#import "StolpersteineReadWriteDataService.h"
#import "StolpersteinSynchronizationControllerDelegate.h"

#import "YapDatabase.h"
#import "YapSet.h"
#import "YapCollectionKey.h"

@interface StolpersteineSynchronizationController()

@property (nonatomic, strong) StolpersteineNetworkService *networkService;
@property (nonatomic, strong) StolpersteineReadDataService *readDataService;
@property (nonatomic, strong) StolpersteineReadWriteDataService *readWriteDataService;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, assign, getter = isSynchronizing) BOOL synchronizing;

@end

@implementation StolpersteineSynchronizationController

- (id)initWithNetworkService:(StolpersteineNetworkService *)networkService
{
    self = [super init];
    if (self) {
        _networkService = networkService;
        _readWriteDataService = [[StolpersteineReadWriteDataService alloc] init];
        _readDataService = [[StolpersteineReadDataService alloc] init];
        [_readDataService.connection beginLongLivedReadTransaction];
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(databaseChanged) name:YapDatabaseModifiedNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)databaseChanged
{
    BOOL respondsToAddStolpersteine = [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)];
    BOOL respondsToUpdateStolpersteine = [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didUpdateStolpersteine:)];
    BOOL respondsToRemoveStolpersteine = [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didRemoveStolpersteine:)];

    NSArray *notifications = [self.readDataService.connection beginLongLivedReadTransaction];
    for (NSNotification *notification in notifications)
	{
        NSAssert([notification.userInfo objectForKey:YapDatabaseConnectionKey] == self.readWriteDataService.connection, @"Invalid connection");
                 
		NSDictionary *changes = [notification.userInfo objectForKey:YapDatabaseCustomKey];
        
        if (respondsToAddStolpersteine) {
            NSArray *addedIDs = [changes objectForKey:StolpersteineReadWriteDataServiceAddedIDsKey];
            [self.readDataService retrieveStolpersteinWithIDs:addedIDs completionHandler:^(NSArray *stolpersteine) {
                [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:stolpersteine];
            }];
        }
        
        if (respondsToUpdateStolpersteine) {
            NSArray *updatedIDs = [changes objectForKey:StolpersteineReadWriteDataServiceUpdatedIDsKey];
            [self.readDataService retrieveStolpersteinWithIDs:updatedIDs completionHandler:^(NSArray *stolpersteine) {
                [self.delegate stolpersteinSynchronizationController:self didUpdateStolpersteine:stolpersteine];
            }];
        }

        if (respondsToRemoveStolpersteine) {
            NSArray *removedIDs = [changes objectForKey:StolpersteineReadWriteDataServiceUpdatedIDsKey];
            [self.readDataService retrieveStolpersteinWithIDs:removedIDs completionHandler:^(NSArray *stolpersteine) {
                [self.delegate stolpersteinSynchronizationController:self didRemoveStolpersteine:stolpersteine];
            }];
        }
    }
}

- (void)synchronize
{
    [self retrieveStolpersteineFromDatabase];
    
    if (!self.isSynchronizing) {
        [self didStartSynchronization];
        
        [self retrieveStolpersteineFromServer];
    }
}

- (void)retrieveStolpersteineFromDatabase
{
    [self.readDataService retrieveStolpersteineWithRange:NSMakeRange(0, UINT_MAX) completionHandler:^(NSArray *stolpersteine) {
        if ([self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)]) {
            [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:stolpersteine];
        }
    }];
}

- (void)retrieveStolpersteineFromServer
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [self.networkService retrieveStolpersteineWithSearchData:nil range:NSMakeRange(0, 0) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        if (error == nil) {
            [self.readWriteDataService createOrUpdateStolpersteine:stolpersteine completionHandler:^{
                [self didEndSynchronization];
            }];
        } else {
            [self didFailSynchronization];
        }
        
        return YES;
    }];
}

- (void)didStartSynchronization
{
    self.synchronizing = YES;
}

- (void)didEndSynchronization
{
    self.synchronizing = NO;
}

- (void)didFailSynchronization
{
    self.synchronizing = NO;
}

@end
