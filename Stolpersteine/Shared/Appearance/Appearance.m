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
    [Appearance applyCustomButtonAppearance];
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

+ (void)applyCustomButtonAppearance
{
//    UIButton *button = [UIButton appearanceWhenContainedIn:UIScrollView.class, nil];
//    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
//    [button setTitle:title forState:UIControlStateNormal];
//    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
//    UIImage *backgroundImage = [[UIImage imageNamed:@"rounded-rect-frame.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
//    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
//    [button setTintColor:UIColor.orangeColor];
    
//    if (chevronEnabled) {
//        UIImage *chevron = [UIImage imageNamed:@"icon-chevron.png"];
//        [button setImage:chevron forState:UIControlStateNormal];
//        [button sizeToFit];
//        button.titleEdgeInsets = UIEdgeInsetsMake(0, -chevron.size.width, 0, 0);
//    }
}

@end
