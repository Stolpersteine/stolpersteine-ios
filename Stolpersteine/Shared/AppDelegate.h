//
//  AppDelegate.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "StolpersteinNetworkServiceDelegate.h"

@class StolpersteinNetworkService;
@class DiagnosticsService;

@interface AppDelegate : UIResponder <UIApplicationDelegate, StolpersteinNetworkServiceDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StolpersteinNetworkService *networkService;
@property (strong, nonatomic) DiagnosticsService *diagnosticsService;

+ (StolpersteinNetworkService *)networkService;
+ (DiagnosticsService *)diagnosticsService;

@end
