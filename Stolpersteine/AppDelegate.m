//
//  AppDelegate.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "AppDelegate.h"

#import "StolpersteineNetworkService.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.networkService = [[StolpersteineNetworkService alloc] initWithURL:nil clientUser:nil clientPassword:nil];
    [self.networkService retrieveStolpersteineWithSearchData:nil page:0 pageSize:0 completionHandler:^(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error) {
        NSLog(@"retrieveStolpersteineWithSearchData done");
    }];
    
    return YES;
}
							
@end
