//
//  ViewTransitionSegue.m
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGallerySegue.h"

#import "FullScreenImageGalleryViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation FullScreenImageGallerySegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    FullScreenImageGalleryViewController *destinationViewController = self.destinationViewController;
    UIViewController *rootViewController = UIApplication.sharedApplication.keyWindow.rootViewController;

    // Animations to present the view controller
    destinationViewController.view.frame = UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds;
    [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        UIApplication.sharedApplication.keyWindow.rootViewController = destinationViewController;
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {
    }];
    
    // Animations to dismiss the view controller
    destinationViewController.completionBlock = ^() {
        sourceViewController.view.frame = UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds;
        [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            UIApplication.sharedApplication.keyWindow.rootViewController = rootViewController;
        } completion:^(BOOL finished) {
        }];
    };
}

@end
