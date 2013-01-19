//
//  NavigationController.m
//  Stolpersteine
//
//  Created by Claus on 19.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "NavigationController.h"

@implementation NavigationController

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(interfaceOrientation) || (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
