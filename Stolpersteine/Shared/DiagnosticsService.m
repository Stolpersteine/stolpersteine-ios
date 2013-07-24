//
//  Diagnostics.m
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

#import "DiagnosticsService.h"

#import "GAI.h"
#import "GAITracker.h"

#import "MapViewController.h"
#import "SearchDisplayController.h"
#import "StolpersteinDetailViewController.h"
#import "StolpersteinListViewController.h"

#define CUSTOM_DIMENSION_INTERFACE_ORIENTATION 1
#define CUSTOM_DIMENSION_LOCATION_SERVICES 2

@interface DiagnosticsService()

@property (nonatomic, strong) GAI *gai;
@property (nonatomic, strong) id<GAITracker> gaiTracker;
@property (nonatomic, strong) NSDictionary *classToViewNameMapping;
@property (nonatomic, strong) NSDictionary *eventToActionNameMapping;

@end

@implementation DiagnosticsService

- (id)initWithGoogleAnalyticsID:(NSString *)googleAnayticsID
{
    self = [super init];
    if (self) {
        self.gai = GAI.sharedInstance;
        self.gai.trackUncaughtExceptions = YES;
        self.gai.dispatchInterval = 30;
//        self.gai.debug = YES;
        self.gaiTracker = [self.gai trackerWithTrackingId:googleAnayticsID];
        self.gaiTracker.anonymize = YES;
        NSDictionary *infoDictionary = [NSBundle.mainBundle infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        self.gaiTracker.appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
        
        // Mappings
        self.classToViewNameMapping = @{
           NSStringFromClass(MapViewController.class): @"Map",
           NSStringFromClass(SearchDisplayController.class): @"SearchDisplay",
           NSStringFromClass(StolpersteinDetailViewController.class): @"StolpersteinDetail",
           NSStringFromClass(StolpersteinListViewController.class): @"StolpersteinList"
        };
        self.eventToActionNameMapping = @{
            @(DiagnosticsServiceEventOrientationChanged): @"orientationChanged"
        };
        
        // Register for changes to user settings
        [self userDefaultsDidChange];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(userDefaultsDidChange) name:NSUserDefaultsDidChangeNotification object:nil];
        
        // Register for orientation changes
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(applicationDidChangeStatusBarOrientationWithNotification:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)userDefaultsDidChange
{
    NSString *sendDiagnosticsAsString = [NSUserDefaults.standardUserDefaults stringForKey:@"Settings.sendDiagnostics"];
    BOOL sendDiagnostics = (sendDiagnosticsAsString == nil) || sendDiagnosticsAsString.boolValue;
    self.gai.optOut = !sendDiagnostics;
}

- (NSString *)stringForClass:(Class)class
{
    NSString *className = NSStringFromClass(class);
    NSString *string = [self.classToViewNameMapping objectForKey:className];
    NSAssert(string != nil, @"Unknown class for tracking: %@", className);
    
    return string;
}

- (NSString *)stringForEvent:(DiagnosticsServiceEvent)event
{
    NSString *string = [self.eventToActionNameMapping objectForKey:@(event)];
    NSAssert(string != nil, @"Unknown event for tracking: %d", event);
    
    return string;
}

+ (NSString *)stringForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? @"landscape" : @"portrait";
}

+ (NSString *)stringForAuthorizationStatus:(CLAuthorizationStatus)authorizationStatus
{
    NSString *string;
    if (authorizationStatus == kCLAuthorizationStatusAuthorized) {
        string = @"on";
    } else if (authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted) {
        string = @"off";
    } else {
        string = @"unknown";
    }
    
    return string;
}

- (void)applicationDidChangeStatusBarOrientationWithNotification:(NSNotification *)note
{
    UIInterfaceOrientation interfaceOrientationOld = [[note.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    BOOL isLandscapeOld = UIInterfaceOrientationIsLandscape(interfaceOrientationOld);
    UIInterfaceOrientation interfaceOrientationNew = UIApplication.sharedApplication.statusBarOrientation;
    BOOL isLandscapeNew = UIInterfaceOrientationIsLandscape(interfaceOrientationNew);
    if (isLandscapeOld != isLandscapeNew) {
        NSString *actionName = [self stringForEvent:DiagnosticsServiceEventOrientationChanged];
        NSString *viewName = self.gaiTracker.appScreen; // last used view name
        NSString *interfaceOrientationAsString = [DiagnosticsService stringForInterfaceOrientation:interfaceOrientationNew];
        if (actionName && viewName) {
            [self addCustomDimensions];
            [self.gaiTracker sendEventWithCategory:viewName withAction:actionName withLabel:interfaceOrientationAsString withValue:nil];
        }
    }
}

- (void)addCustomDimensions
{
    UIInterfaceOrientation interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
    NSString *interfaceOrientationAsString = [DiagnosticsService stringForInterfaceOrientation:interfaceOrientation];
    [self.gaiTracker setCustom:CUSTOM_DIMENSION_INTERFACE_ORIENTATION dimension:interfaceOrientationAsString];
    
    CLAuthorizationStatus authorizationStatus = CLLocationManager.authorizationStatus;
    NSString *authorizationStatusAsString = [DiagnosticsService stringForAuthorizationStatus:authorizationStatus];
    [self.gaiTracker setCustom:CUSTOM_DIMENSION_LOCATION_SERVICES dimension:authorizationStatusAsString];
}

- (void)trackViewWithClass:(Class)class
{
    NSString *viewName = [self stringForClass:class];
    if (viewName) {
        [self addCustomDimensions];
        [self.gaiTracker sendView:viewName];
    }
}

- (void)trackEvent:(DiagnosticsServiceEvent)event withClass:(Class)class
{
    NSString *actionName = [self stringForEvent:event];
    NSString *viewName = [self stringForClass:class];
    if (actionName && viewName) {
        [self addCustomDimensions];
        [self.gaiTracker sendEventWithCategory:viewName withAction:actionName withLabel:nil withValue:nil];
    }
}

@end
