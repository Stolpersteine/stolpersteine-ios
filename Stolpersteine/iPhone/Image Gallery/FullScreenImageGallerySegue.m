//
//  ViewTransitionSegue.m
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGallerySegue.h"

#import "StolpersteinDetailViewController.h"
#import "FullScreenImageGalleryViewController.h"
#import "ImageGalleryView.h"

#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION 0.3f

@implementation FullScreenImageGallerySegue

- (void)perform
{
    StolpersteinDetailViewController *stolpersteinDetailViewController = self.sourceViewController;
    FullScreenImageGalleryViewController *fullScreenImageGalleryViewController = self.destinationViewController;
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    UIViewController *rootViewController = window.rootViewController;
    UIView *imageGalleryViewSuperView = self.imageGalleryView.superview;
    CGRect imageGalleryViewWindowFrame = [window convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];

    // Steps to present the view controller
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    fullScreenImageGalleryViewController.view.frame = rootViewController.view.bounds;
    fullScreenImageGalleryViewController.imageGalleryView = self.imageGalleryView;
    
    UIView *backgroundView = [[UIView alloc] initWithFrame:window.frame];
    backgroundView.backgroundColor = UIColor.blackColor;
    backgroundView.alpha = 0;
    [window addSubview:backgroundView];

    CGRect windowFrame = [window convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
    self.imageGalleryView.frame = windowFrame;
    [window addSubview:self.imageGalleryView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        backgroundView.alpha = 1;
        self.imageGalleryView.frame = fullScreenImageGalleryViewController.view.frame;
    } completion:^(BOOL finished) {
        [backgroundView removeFromSuperview];
        
        CGRect fullScreenFrame = [fullScreenImageGalleryViewController.view convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
        self.imageGalleryView.frame = fullScreenFrame;
        [fullScreenImageGalleryViewController.view addSubview:self.imageGalleryView];
        [stolpersteinDetailViewController presentViewController:fullScreenImageGalleryViewController animated:NO completion:NULL];
    }];

    // Steps to dismiss the view controller
    fullScreenImageGalleryViewController.completionBlock = ^() {
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [stolpersteinDetailViewController dismissViewControllerAnimated:NO completion:NULL];

        UIView *backgroundView = [[UIView alloc] initWithFrame:window.frame];
        backgroundView.backgroundColor = UIColor.blackColor;
        backgroundView.alpha = 1;
        [window addSubview:backgroundView];

        CGRect windowFrame = [window convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
        self.imageGalleryView.frame = windowFrame;
        [window addSubview:self.imageGalleryView];
        
        [UIView animateWithDuration:ANIMATION_DURATION animations:^{
            backgroundView.alpha = 0;
            self.imageGalleryView.frame = imageGalleryViewWindowFrame;
        } completion:^(BOOL finished) {
            [backgroundView removeFromSuperview];
            
            CGRect fullScreenFrame = [imageGalleryViewSuperView convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
            self.imageGalleryView.frame = fullScreenFrame;
            [imageGalleryViewSuperView addSubview:self.imageGalleryView];
            stolpersteinDetailViewController.imageGalleryView = self.imageGalleryView;
        }];
    };
}

@end
