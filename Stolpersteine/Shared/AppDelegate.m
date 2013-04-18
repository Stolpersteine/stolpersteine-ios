//
//  AppDelegate.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "AppDelegate.h"

#import "StolpersteinNetworkService.h"
#import "DiagnosticsService.h"

#ifdef DEBUG
@interface NSURLRequest (HTTPS)
+ (void)setAllowsAnyHTTPSCertificate:(BOOL)allow forHost:(NSString *)host;
@end
#endif

static NSString * const API_URL = @"https://stolpersteine-api.eu01.aws.af.cm/v1/";
static NSString * const GOOGLE_ANALYTICS_ID = @"UA-38166041-1";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Works around bug on iPad when app is started in landscape mode
    UIInterfaceOrientation orientation = application.statusBarOrientation;
    application.statusBarOrientation = UIInterfaceOrientationPortrait;
    application.statusBarOrientation = orientation;
    
    NSURL *url = [NSURL URLWithString:API_URL];
    self.networkService = [[StolpersteinNetworkService alloc] initWithURL:url clientUser:nil clientPassword:nil];
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the network traffic
    [NSURLRequest setAllowsAnyHTTPSCertificate:YES forHost:url.host];
#endif
    
    // Google Analytics
    self.diagnosticsService = [[DiagnosticsService alloc] initWithGoogleAnalyticsID:GOOGLE_ANALYTICS_ID];
    
    // Appearance
    UINavigationBar *navigationBar = UINavigationBar.appearance;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-portrait.png"] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-landscape.png"] forBarMetrics:UIBarMetricsLandscapePhone];
    UIColor *grayColor = [UIColor colorWithRed:115.0f/255.0f green:120.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    UIColor *lightGrayColor = [UIColor colorWithRed:239.0f/255.0f green:230.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    NSDictionary *navigationBarTitleTextAttributes = @{ UITextAttributeTextColor: grayColor,
                                                        UITextAttributeTextShadowColor: lightGrayColor,
                                                        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)] };
    navigationBar.titleTextAttributes = navigationBarTitleTextAttributes;
    navigationBar.tintColor = [UIColor colorWithRed:143.0f/255.0f green:147.0f/255.0f blue:155.0f/255.0f alpha:1.0f];;
    return YES;
}

+ (StolpersteinNetworkService *)networkService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.networkService;
}

+ (DiagnosticsService *)diagnosticsService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.diagnosticsService;
}
							
@end
