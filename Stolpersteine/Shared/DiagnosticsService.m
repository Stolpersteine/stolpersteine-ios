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
#import "GAIFields.h"
#import "GAIDictionaryBuilder.h"

#import "MapViewController.h"
#import "MapSearchDisplayController.h"
#import "InfoViewController.h"
#import "StolpersteinCardsViewController.h"
#import "StolpersteinDescriptionViewController.h"
#import "AppDelegate.h"

#import <CoreLocation/CoreLocation.h>

#define CUSTOM_DIMENSION_INTERFACE_ORIENTATION 1
#define CUSTOM_DIMENSION_LOCATION_SERVICES 2

@interface DiagnosticsService()

@property (nonatomic) GAI *gai;
@property (nonatomic) id<GAITracker> gaiTracker;
@property (nonatomic, copy) NSDictionary *classToViewNameMapping;
@property (nonatomic, copy) NSDictionary *eventToActionNameMapping;

@end

@implementation DiagnosticsService

- (instancetype)initWithGoogleAnalyticsID:(NSString *)googleAnayticsID
{
    self = [super init];
    if (self) {
        _gai = GAI.sharedInstance;
        _gai.trackUncaughtExceptions = YES;
        _gai.dispatchInterval = 30;
//        [_gai.logger setLogLevel:kGAILogLevelVerbose];
//        _gai.dryRun = YES;
        _gaiTracker = [self.gai trackerWithTrackingId:googleAnayticsID];
        [_gaiTracker set:kGAIAnonymizeIp value:[@NO stringValue]];
        NSDictionary *infoDictionary = [NSBundle.mainBundle infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        [_gaiTracker set:kGAIAppVersion value:[NSString stringWithFormat:@"%@ (%@)", shortVersion, version]];
        
        // Mappings
        _classToViewNameMapping = @{
           NSStringFromClass(AppDelegate.class): @"Misc",
           NSStringFromClass(MapViewController.class): @"Map",
           NSStringFromClass(MapSearchDisplayController.class): @"Map",
           NSStringFromClass(InfoViewController.class): @"Info",
           NSStringFromClass(StolpersteinCardsViewController.class): @"StolpersteinCards",
           NSStringFromClass(StolpersteinDescriptionViewController.class): @"StolpersteinDescription"
        };
        _eventToActionNameMapping = @{
            @(DiagnosticsServiceEventOrientationChanged): @"orientationChanged",
            @(DiagnosticsServiceEventSearchStarted): @"searchStarted",
            @(DiagnosticsServiceEventMapCentered): @"mapCentered",
            @(DiagnosticsServiceEventInfoItemTapped): @"infoItemTapped"
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
        NSString *viewName = [self.gaiTracker get:kGAIScreenName]; // last used view name
        NSString *interfaceOrientationAsString = [DiagnosticsService stringForInterfaceOrientation:interfaceOrientationNew];
        if (actionName && viewName) {
            [self updateCustomDimensions];
            NSDictionary *data = [[GAIDictionaryBuilder createEventWithCategory:viewName action:actionName label:interfaceOrientationAsString value:nil] build];
            [self.gaiTracker send:data];
        }
    }
}

- (void)updateCustomDimensions
{
    UIInterfaceOrientation interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
    NSString *interfaceOrientationAsString = [DiagnosticsService stringForInterfaceOrientation:interfaceOrientation];
    NSString *interfaceOrientationDimension = [GAIFields customDimensionForIndex:CUSTOM_DIMENSION_INTERFACE_ORIENTATION];
    [self.gaiTracker set:interfaceOrientationAsString value:interfaceOrientationDimension];
    
    CLAuthorizationStatus authorizationStatus = CLLocationManager.authorizationStatus;
    NSString *authorizationStatusAsString = [DiagnosticsService stringForAuthorizationStatus:authorizationStatus];
    NSString *locationServicesDimension = [GAIFields customDimensionForIndex:CUSTOM_DIMENSION_LOCATION_SERVICES];
    [self.gaiTracker set:authorizationStatusAsString value:locationServicesDimension];
}

- (void)trackViewWithClass:(Class)class
{
    NSString *viewName = [self stringForClass:class];
    if (viewName) {
        [self updateCustomDimensions];
        [self.gaiTracker set:kGAIScreenName value:viewName];
        NSDictionary *data = [[GAIDictionaryBuilder createScreenView] build];
        [self.gaiTracker send:data];
    }
}

- (void)trackEvent:(DiagnosticsServiceEvent)event withClass:(Class)class
{
    [self trackEvent:event withClass:class label:nil];
}

- (void)trackEvent:(DiagnosticsServiceEvent)event withClass:(Class)class label:(NSString *)label
{
    NSString *actionName = [self stringForEvent:event];
    NSString *viewName = [self stringForClass:class];
    if (actionName && viewName) {
        [self updateCustomDimensions];
        NSDictionary *data = [[GAIDictionaryBuilder createEventWithCategory:viewName action:actionName label:label value:nil] build];
        [self.gaiTracker send:data];
    }
}

@end
