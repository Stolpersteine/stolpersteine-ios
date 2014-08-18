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
#import "StolpersteinSynchronizationControllerDelegate.h"

#define NETWORK_BATCH_SIZE 500

@interface StolpersteineSynchronizationController()

@property (nonatomic) StolpersteineNetworkService *networkService;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, getter = isSynchronizing) BOOL synchronizing;
@property (nonatomic) NSMutableSet *stolpersteine;

@end

@implementation StolpersteineSynchronizationController

- (instancetype)initWithNetworkService:(StolpersteineNetworkService *)networkService
{
    self = [super init];
    if (self) {
        _networkService = networkService;
        _stolpersteine = [NSMutableSet setWithCapacity:NETWORK_BATCH_SIZE];
    }
    
    return self;
}

- (void)synchronize
{
    if (!self.isSynchronizing) {
        [self didStartSynchronization];
        
        NSRange range = NSMakeRange(0, NETWORK_BATCH_SIZE);
        [self retrieveStolpersteineWithRange:range];
    }
}

- (void)retrieveStolpersteineWithRange:(NSRange)range
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [self.networkService retrieveStolpersteineWithSearchData:nil range:range completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        if (error == nil) {
            [self didAddStolpersteine:stolpersteine];
            
            if (stolpersteine.count == range.length) {
                // Next batch of data
                NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
                [self retrieveStolpersteineWithRange:nextRange];
            } else {
                [self didEndSynchronization];
            }
        } else {
            [self didFailSynchronization];
        }
        
        return (self.stolpersteine.count == 0);
    }];
}

- (void)didAddStolpersteine:(NSArray *)stolpersteine
{
    // Filter out items that are already on the map
    NSMutableSet *additionalStolpersteineAsSet = [NSMutableSet setWithArray:stolpersteine];
    [additionalStolpersteineAsSet minusSet:self.stolpersteine];
    NSArray *additionalStolpersteine = additionalStolpersteineAsSet.allObjects;
    [self.stolpersteine addObjectsFromArray:additionalStolpersteine];
    
    // Tell delegate about additional items
    if (additionalStolpersteine.count > 0 && [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)]) {
        [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:additionalStolpersteine];
    }
    
//    // Store locally
//    [self.readWriteDataService createStolpersteine:additionalStolpersteine completionHandler:^{
//        // Tell delegate about additional items
//        if (additionalStolpersteine.count > 0 && [self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)]) {
//            [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:additionalStolpersteine];
//        }
//    }];
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
