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

@end

@implementation DiagnosticsService

- (id)initWithGoogleAnalyticsID:(NSString *)googleAnayticsID
{
    self = [super init];
    if (self) {
        self.gai = GAI.sharedInstance;
        self.gai.trackUncaughtExceptions = YES;
        self.gai.debug = YES;
        self.gaiTracker = [self.gai trackerWithTrackingId:googleAnayticsID];
        self.gaiTracker.anonymize = TRUE;
        NSDictionary* infoDictionary = [NSBundle.mainBundle infoDictionary];
        NSString* version = [infoDictionary objectForKey:@"CFBundleVersion"];
        NSString* shortVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
        self.gaiTracker.appVersion = [NSString stringWithFormat:@"%@ (%@)", shortVersion, version];
        
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

@end
