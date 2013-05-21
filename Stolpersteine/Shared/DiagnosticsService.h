//
//  Diagnostics.h
//  Stolpersteine
//
//  Created by Claus on 07.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#define DIAGNOSTICS_SERVICE_EVENT_ACTION_ORIENTATION_CHANGED @"OrientationChanged"

@interface DiagnosticsService : NSObject

- (id)initWithGoogleAnalyticsID:(NSString *)googleAnayticsID;
- (void)trackViewController:(UIViewController *)viewController;

@end
