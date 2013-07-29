//
//  StolpersteinSynchronizationController.m
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

#import "StolpersteinSynchronizationController.h"

#import "StolpersteinNetworkService.h"
#import "StolpersteinSynchronizationControllerDelegate.h"

#define NETWORK_BATCH_SIZE 500

@interface StolpersteinSynchronizationController()

@property (nonatomic, strong) StolpersteinNetworkService *networkService;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, assign, getter = isSynchronizing) BOOL synchronizing;

@end

@implementation StolpersteinSynchronizationController

- (id)initWithNetworkService:(StolpersteinNetworkService *)networkService
{
    self = [super init];
    if (self) {
        self.networkService = networkService;
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
        
        return YES;
    }];
}

- (void)didAddStolpersteine:(NSArray *)stolpersteine
{
    if ([self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didAddStolpersteine:)]) {
        [self.delegate stolpersteinSynchronizationController:self didAddStolpersteine:stolpersteine];
    }
}

- (void)didRemoveStolpersteine:(NSArray *)stolpersteine
{
    if ([self.delegate respondsToSelector:@selector(stolpersteinSynchronizationController:didRemoveStolpersteine:)]) {
        [self.delegate stolpersteinSynchronizationController:self didRemoveStolpersteine:stolpersteine];
    }    
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
