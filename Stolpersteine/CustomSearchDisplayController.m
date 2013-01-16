//
//  CustomSearchDisplayController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "CustomSearchDisplayController.h"

@implementation CustomSearchDisplayController

- (void)setActive:(BOOL)visible animated:(BOOL)animated
{
    // This disables the animation to hide the navigation bar
    [super setActive:visible animated:animated];
    [self.searchContentsController.navigationController setNavigationBarHidden:NO animated:NO];
}

@end
