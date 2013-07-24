//
//  Appearance.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
