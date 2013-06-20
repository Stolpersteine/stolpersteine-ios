//
//  StolpersteinNetworkServiceDelegate.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 20.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class StolpersteinNetworkService;

@protocol StolpersteinNetworkServiceDelegate <NSObject>

@optional
- (void)stolpersteinNetworkService:(StolpersteinNetworkService *)stolpersteinNetworkService handleError:(NSError *)error;

@end
