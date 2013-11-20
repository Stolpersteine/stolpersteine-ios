//
//  AppDelegate.m
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

#import "AppDelegate.h"

#import "StolpersteinNetworkService.h"
#import "StolpersteinSearchData.h"
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
    // Early out when running unit tests
    BOOL runningTests = NSClassFromString(@"XCTestCase") != nil;
    if (runningTests) {
        return YES;
    }

    // App version info
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
    self.networkService.defaultSearchData.city = @"Berlin";
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
