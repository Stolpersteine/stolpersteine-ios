//
//  Localization.h
//  Stolpersteine
//
//  Created by Claus on 25.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stolperstein;

@interface Localization : NSObject

+ (NSString *)newAddressFromStolperstein:(Stolperstein *)stolperstein;

@end
