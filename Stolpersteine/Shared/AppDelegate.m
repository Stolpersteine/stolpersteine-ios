//
//  AppDelegate.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "AppDelegate.h"

#import "StolpersteinNetworkService.h"
#import "GAI.h"

#ifdef DEBUG
@interface NSURLRequest (HTTPS)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end
#endif

static NSString * const API_URL = @"https://stolpersteine-optionu.rhcloud.com/api/";
static NSString * const GOOGLE_ANALYTICS_ID = @"UA-38166041-1";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSURL *url = [NSURL URLWithString:API_URL];
    self.networkService = [[StolpersteinNetworkService alloc] initWithURL:url clientUser:nil clientPassword:nil];
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the traffic.
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:url.host];
#endif
    
    // Google Analytics
//    GAI.sharedInstance.trackUncaughtExceptions = YES;
//    GAI.sharedInstance.dispatchInterval = 60;
//    GAI.sharedInstance.debug = YES;
//    id<GAITracker> tracker = [GAI.sharedInstance trackerWithTrackingId:GOOGLE_ANALYTICS_ID];
//    [tracker sendView:@"MapView"];
    
    return YES;
}

+ (StolpersteinNetworkService *)networkService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.networkService;
}
							
@end
