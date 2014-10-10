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

#import "StolpersteineNetworkService.h"
#import "StolpersteineSearchData.h"
#import "DiagnosticsService.h"
#import "ConfigurationService.h"

@interface AppDelegate()

@property (nonatomic) StolpersteineNetworkService *networkService;
@property (nonatomic) DiagnosticsService *diagnosticsService;
@property (nonatomic) ConfigurationService *configurationService;

@end

@implementation AppDelegate

+ (StolpersteineNetworkService *)networkService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.networkService;
}

+ (DiagnosticsService *)diagnosticsService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.diagnosticsService;
}

+ (ConfigurationService *)configurationService
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    return appDelegate.configurationService;
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
    NSLog(@"Stolpersteine %@ (%@)", [ConfigurationService appShortVersion], [ConfigurationService appVersion]);
    
    // Configuration service
    NSString *configurationsFile = [NSBundle.mainBundle pathForResource:@"Stolpersteine-Config" ofType:@"plist"];
    self.configurationService = [[ConfigurationService alloc] initWithConfigurationsFile:configurationsFile];
    
    // Network service
    NSString *clientUser = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIUser];
    NSString *clientPassword = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyAPIPassword];
    self.networkService = [[StolpersteineNetworkService alloc] initWithClientUser:clientUser clientPassword:clientPassword];
    NSString *city = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyFilterCity];
    self.networkService.defaultSearchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:nil city:city];
    self.networkService.delegate = self;
#ifdef DEBUG
    // This allows invalid certificates so that proxies can decrypt the network traffic
    self.networkService.allowsInvalidSSLCertificate = YES;
#endif
    
    // Google Analytics
    NSString *googleAnalyticsID = [self.configurationService stringConfigurationForKey:ConfigurationServiceKeyGoogleAnalyticsID];
    self.diagnosticsService = [[DiagnosticsService alloc] initWithGoogleAnalyticsID:googleAnalyticsID];
    
    return YES;
}

#pragma mark - Stolperstein network service

- (void)stolpersteinNetworkService:(StolpersteineNetworkService *)stolpersteinNetworkService handleError:(NSError *)error
{
    NSString *errorTitle = NSLocalizedString(@"AppDelegate.errorTitle", nil);
    NSString *errorMessage = NSLocalizedString(@"AppDelegate.errorMessage", nil);
    NSString *errorButtonTitle = NSLocalizedString(@"AppDelegate.errorButtonTitle", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:errorTitle message:errorMessage delegate:nil cancelButtonTitle:errorButtonTitle otherButtonTitles:nil];
    [alert show];
}

@end
