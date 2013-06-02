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
#import "AGWindowView.h"

#import <QuartzCore/QuartzCore.h>

#define ANIMATION_DURATION 0.3f

@interface FullScreenImageGallerySegue()

@property (nonatomic, strong) FullScreenImageGallerySegue *cycle;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imageGalleryViewSuperView;
@property (nonatomic, assign) CGRect imageGalleryViewWindowFrame;


@end

@implementation FullScreenImageGallerySegue

- (void)perform
{
    // Steps to present the view controller
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.cycle = self;
    
    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;

    self.imageGalleryViewSuperView = self.imageGalleryView.superview;
    self.imageGalleryViewWindowFrame = [windowView convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
    
    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = UIColor.blackColor;
    self.backgroundView.alpha = 0;
    [windowView addSubview:self.backgroundView];
    [windowView addSubViewAndKeepSamePosition:self.imageGalleryView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 1;
        self.imageGalleryView.frame = windowView.bounds;
    } completion:^(BOOL finished) {
    }];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done)];
    [self.imageGalleryView addGestureRecognizer:tapGestureRecognizer];
}

- (void)done
{
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    StolpersteinDetailViewController *stolpersteinDetailViewController = self.sourceViewController;
    
    [stolpersteinDetailViewController.navigationController setNavigationBarHidden:YES];
    [stolpersteinDetailViewController.navigationController setNavigationBarHidden:NO];
    
    AGWindowView *windowView = [AGWindowView activeWindowViewContainingView:self.imageGalleryView];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 0;
        self.imageGalleryView.frame = self.imageGalleryViewWindowFrame;
    } completion:^(BOOL finished) {
        [windowView removeFromSuperview];

        CGRect fullScreenFrame = [self.imageGalleryViewSuperView convertRect:self.imageGalleryView.frame fromView:self.imageGalleryView.superview];
        self.imageGalleryView.frame = fullScreenFrame;
        [self.imageGalleryViewSuperView addSubview:self.imageGalleryView];
        stolpersteinDetailViewController.imageGalleryView = self.imageGalleryView;
    }];
}

@end
