//
//  Diagnostics.m
//  Stolpersteine
//
//  Created by Claus on 07.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "DiagnosticsService.h"

#import "GAI.h"
#import "GAITracker.h"

@interface DiagnosticsService()

@property (nonatomic, strong) GAI *gai;
@property (nonatomic, strong) id<GAITracker> gaiTracker;
@property (nonatomic, strong) NSDictionary *viewControllerToViewName;

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
        self.gaiTracker.anonymize = TRUE;
        NSDictionary *infoDictionary = [NSBundle.mainBundle infoDictionary];
        NSString *version = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString *shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        self.gaiTracker.appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
        
        // Name maping
        self.viewControllerToViewName = @{
            @"MapViewController": @"Map",
            @"StolpersteinDetailViewController": @"StolpersteinDetail",
            @"StolpersteinListViewController": @"StolpersteinList",
            @"FullScreenImageGalleryViewController": @"FullScreenImageGallery"
        };
        
        // Register for changes to user settings
        [self refreshSettings];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(refreshSettings) name:NSUserDefaultsDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)refreshSettings
{
    NSString *sendDiagnosticsAsString = [NSUserDefaults.standardUserDefaults stringForKey:@"Settings.sendDiagnostics"];
    BOOL sendDiagnostics = (sendDiagnosticsAsString == nil) || sendDiagnosticsAsString.boolValue;
    self.gai.optOut = !sendDiagnostics;
}

- (void)trackViewController:(UIViewController *)viewController
{
    NSString *viewControllerName = NSStringFromClass(viewController.class);
    NSString *viewName = [self.viewControllerToViewName objectForKey:viewControllerName];
    NSAssert(viewName != nil, @"Unknown view controller name for tracking");

    if (viewName) {
        [self.gaiTracker sendView:viewName];
    }
}

@end
