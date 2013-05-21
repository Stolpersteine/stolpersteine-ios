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

#define CUSTOM_DIMENSION_INTERFACE_ORIENTATION 1

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
        self.gai.debug = YES;
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

- (NSString *)viewNameForViewController:(UIViewController *)viewController
{
    NSString *className = NSStringFromClass(viewController.class);
    NSString *viewName = [self.viewControllerToViewName objectForKey:className];
    NSAssert(viewName != nil, @"Unknown view controller for tracking");
    
    return viewName;
}

+ (NSString *)orientationNameForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) ? @"landscape" : @"portrait";
}

+ (UIViewController *)topMostViewControllerForRootViewController:(UIViewController *)rootViewController
{
    UIViewController *viewController = rootViewController;
    while (viewController.childViewControllers.count > 0) {
        if ([viewController isKindOfClass:UINavigationController.class]) {
            UINavigationController *navigationController = (UINavigationController *)viewController;
            viewController = navigationController.topViewController;
        } else {
            NSAssert(FALSE, @"Unknown container view controller");
        }
    }
    
    return viewController;
}

+ (UIViewController *)topMostRootViewController
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    
    return rootViewController;
}

- (void)applicationDidChangeStatusBarOrientationWithNotification:(NSNotification *)note
{
    UIInterfaceOrientation interfaceOrientationOld = [[note.userInfo objectForKey:UIApplicationStatusBarOrientationUserInfoKey] intValue];
    BOOL isLandscapeOld = UIInterfaceOrientationIsLandscape(interfaceOrientationOld);
    UIInterfaceOrientation interfaceOrientationNew = UIApplication.sharedApplication.statusBarOrientation;
    BOOL isLandscapeNew = UIInterfaceOrientationIsLandscape(interfaceOrientationNew);
    if (isLandscapeOld != isLandscapeNew) {
        UIViewController *topMostViewController = [DiagnosticsService topMostRootViewController];
        topMostViewController = [DiagnosticsService topMostViewControllerForRootViewController:topMostViewController];
        NSString *viewName = [self viewNameForViewController:topMostViewController];
        if (viewName) {
            NSString *interfaceOrientationAsString = [DiagnosticsService orientationNameForInterfaceOrientation:interfaceOrientationNew];
            [self.gaiTracker sendEventWithCategory:viewName withAction:DIAGNOSTICS_SERVICE_EVENT_ACTION_ORIENTATION_CHANGED withLabel:interfaceOrientationAsString withValue:nil];
        }
    }
}

- (void)addCustomDimensions
{
    UIInterfaceOrientation interfaceOrientation = UIApplication.sharedApplication.statusBarOrientation;
    NSString *interfaceOrientationAsString = [DiagnosticsService orientationNameForInterfaceOrientation:interfaceOrientation];
    [self.gaiTracker setCustom:CUSTOM_DIMENSION_INTERFACE_ORIENTATION dimension:interfaceOrientationAsString];
}

- (void)trackViewController:(UIViewController *)viewController
{
    NSString *viewName = [self viewNameForViewController:viewController];
    if (viewName) {
        [self addCustomDimensions];
        [self.gaiTracker sendView:viewName];
    }
}

@end
