//
//  Diagnostics.h
//  Stolpersteine
//
//  Created by Claus on 07.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    DiagnosticsServiceEventOrientationChanged
} DiagnosticsServiceEvent;

@interface DiagnosticsService : NSObject

- (id)initWithGoogleAnalyticsID:(NSString *)googleAnayticsID;

- (void)trackViewWithClass:(Class)class;
- (void)trackEvent:(DiagnosticsServiceEvent)event withClass:(Class)class;

@end
