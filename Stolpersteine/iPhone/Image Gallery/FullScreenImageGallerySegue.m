//
//  ViewTransitionSegue.m
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGallerySegue.h"

#import "FullScreenImageGalleryViewController.h"
#import "ImageGalleryView.h"

#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION 0.25f

@implementation FullScreenImageGallerySegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    FullScreenImageGalleryViewController *fullScreenImageGalleryViewController = self.destinationViewController;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    UIView *imageGalleryViewSuperView = self.imageGalleryView.superview;

    // Steps to present the view controller
    fullScreenImageGalleryViewController.view.frame = rootViewController.view.bounds;
    fullScreenImageGalleryViewController.imageGalleryView = self.imageGalleryView;
    [UIView transitionWithView:window duration:ANIMATION_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        // Animate view controller transition
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
        window.rootViewController = fullScreenImageGalleryViewController;
    } completion:^(BOOL finished) {
        [fullScreenImageGalleryViewController.view addSubview:self.imageGalleryView];
    }];

    // View animations
//    CGRect windowFrame = [window convertRect:self.animationView.frame fromView:self.animationView.superview];
//    [window addSubview:self.animationView];
//    self.animationView.frame = windowFrame;
//    [UIView animateWithDuration:2 animations:^{
//        self.animationView.transform = CGAffineTransformMakeTranslation(100, 100);
//    }];
    
    // Steps to dismiss the view controller
    __weak FullScreenImageGalleryViewController *weakFullScreenImageGalleryViewController = self.destinationViewController;
    fullScreenImageGalleryViewController.completionBlock = ^() {
        FullScreenImageGalleryViewController *strongFullScreenImageGalleryViewController = weakFullScreenImageGalleryViewController;
        
        // Forward current interface orientation to offscreen view controller
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        window.rootViewController = rootViewController;
        [sourceViewController willRotateToInterfaceOrientation:strongFullScreenImageGalleryViewController.interfaceOrientation duration:0];
        [sourceViewController willAnimateRotationToInterfaceOrientation:strongFullScreenImageGalleryViewController.interfaceOrientation duration:0];
        [sourceViewController didRotateFromInterfaceOrientation:strongFullScreenImageGalleryViewController.interfaceOrientation];
        window.rootViewController = strongFullScreenImageGalleryViewController;
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

        // Add gallery view back
        [imageGalleryViewSuperView addSubview:strongFullScreenImageGalleryViewController.imageGalleryView];

        // Animate view controller transition
        [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:ANIMATION_DURATION options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            window.rootViewController = rootViewController;
        } completion:NULL];
    };
}

@end
