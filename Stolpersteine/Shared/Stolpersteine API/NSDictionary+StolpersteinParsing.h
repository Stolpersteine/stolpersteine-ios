//
//  NSDictionary+Parsing.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 11.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Stolperstein;

@interface NSDictionary (StolpersteinParsing)

- (Stolperstein *)newStolperstein;

@end
