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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Works around bug on iPad when app is started in landscape orientation
    UIInterfaceOrientation orientation = application.statusBarOrientation;
    application.statusBarOrientation = UIInterfaceOrientationPortrait;
    application.statusBarOrientation = orientation;
    
    NSString *version = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *shortVersion = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSLog(@"Stolpersteine %@ (%@)", shortVersion, version);
    
    // Configurations file
    NSString *configurationsFile = [NSBundle.mainBundle pathForResource:@"Stolpersteine-Config" ofType:@"plist"];
    NSDictionary *configurations = [NSDictionary dictionaryWithContentsOfFile:configurationsFile];
    NSString *clientUser = [configurations objectForKey:@"API client user"];
    clientUser = clientUser.length > 0 ? clientUser : nil;
    NSString *clientPassword = [configurations objectForKey:@"API client password"];
    clientPassword = clientPassword.length > 0 ? clientPassword : nil;
    NSString *googleAnalyticsID = [configurations objectForKey:@"Google Analytics ID"];
    googleAnalyticsID = googleAnalyticsID.length > 0 ? googleAnalyticsID : nil;
    
    // Network service
    self.networkService = [[StolpersteinNetworkService alloc] initWithClientUser:clientUser clientPassword:clientPassword];
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the network traffic
    self.networkService.allowsInvalidSSLCertificate = YES;
#endif
    
    // Google Analytics
    self.diagnosticsService = [[DiagnosticsService alloc] initWithGoogleAnalyticsID:googleAnalyticsID];
    
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
