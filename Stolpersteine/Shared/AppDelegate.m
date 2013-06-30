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
#import "Appearance.h"

@implementation AppDelegate

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

#pragma mark - Application

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
    self.networkService.delegate = self;
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the network traffic
    self.networkService.allowsInvalidSSLCertificate = YES;
#endif
    
    // Google Analytics
    self.diagnosticsService = [[DiagnosticsService alloc] initWithGoogleAnalyticsID:googleAnalyticsID];
    
    // Appearance
    [Appearance apply];
    
    return YES;
}

#pragma mark - Stolperstein network service

- (void)stolpersteinNetworkService:(StolpersteinNetworkService *)stolpersteinNetworkService handleError:(NSError *)error
{
    NSString *errorTitle = NSLocalizedString(@"AppDelegate.errorTitle", nil);
    NSString *errorMessage = NSLocalizedString(@"AppDelegate.errorMessage", nil);
    NSString *errorButtonTitle = NSLocalizedString(@"AppDelegate.errorButtonTitle", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:errorButtonTitle otherButtonTitles:nil];
    [alert show];
}

@end
