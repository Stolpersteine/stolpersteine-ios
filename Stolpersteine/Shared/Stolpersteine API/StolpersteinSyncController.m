//
//  StolpersteinSyncController.m
//  Stolpersteine
//
//  Created by Claus on 20.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinSyncController.h"

#import "StolpersteinNetworkService.h"
#import "StolpersteinSyncControllerDelegate.h"

#define NETWORK_BATCH_SIZE 500

@interface StolpersteinSyncController()

@property (nonatomic, strong) StolpersteinNetworkService *networkService;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;

@end

@implementation StolpersteinSyncController

- (id)initWithNetworkService:(StolpersteinNetworkService *)networkService
{
    self = [super init];
    if (self) {
        self.networkService = networkService;
    }
    
    return self;
}

- (void)syncStolpersteine
{
    NSRange range = NSMakeRange(0, NETWORK_BATCH_SIZE);
    [self retrieveStolpersteineWithRange:range];
}

- (void)retrieveStolpersteineWithRange:(NSRange)range
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [self.networkService retrieveStolpersteineWithSearchData:nil range:range completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        if (error == nil) {
            if ([self.delegate respondsToSelector:@selector(stolpersteinSyncController:didAddStolpersteine:)]) {
                [self.delegate stolpersteinSyncController:self didAddStolpersteine:stolpersteine];
            }
            
            // Next batch of data
            if (stolpersteine.count == range.length) {
                NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
                [self retrieveStolpersteineWithRange:nextRange];
            }
        }
        
        return YES;
    }];
}

@end
