//
//  Appearance.m
//  Stolpersteine
//
//  Created by Claus on 30.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "Appearance.h"

@implementation Appearance

+ (void)apply
{
    [Appearance applyCustomNavigationBarAppearance];
}

+ (void)applyCustomNavigationBarAppearance
{
    UINavigationBar *navigationBar = UINavigationBar.appearance;
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-portrait.png"] forBarMetrics:UIBarMetricsDefault];
    [navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation-bar-landscape.png"] forBarMetrics:UIBarMetricsLandscapePhone];
    UIColor *grayColor = [UIColor colorWithRed:115.0f/255.0f green:120.0f/255.0f blue:128.0f/255.0f alpha:1.0f];
    UIColor *lightGrayColor = [UIColor colorWithRed:239.0f/255.0f green:230.0f/255.0f blue:234.0f/255.0f alpha:1.0f];
    NSDictionary *navigationBarTitleTextAttributes = @{ UITextAttributeTextColor: grayColor,
                                                        UITextAttributeTextShadowColor: lightGrayColor,
                                                        UITextAttributeTextShadowOffset: [NSValue valueWithUIOffset:UIOffsetMake(0, 1)] };
    navigationBar.titleTextAttributes = navigationBarTitleTextAttributes;
    navigationBar.tintColor = [UIColor colorWithRed:143.0f/255.0f green:147.0f/255.0f blue:155.0f/255.0f alpha:1.0f];;
}

@end
