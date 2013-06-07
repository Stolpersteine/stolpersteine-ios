//
//  ImageGalleryViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 06.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryViewController.h"

#import "ProgressImageView.h"
#import "ImageGalleryView.h"
#import "ImageGalleryItemView.h"
#import "AGWindowView.h"

#define ITEM_IDENTIFIER @"item"
#define ANIMATION_DURATION 0.3f

@interface ImageGalleryViewController()<UIScrollViewDelegate>

@property (nonatomic, strong) ImageGalleryView *imageGalleryView;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imageGalleryViewSuperView;
@property (nonatomic, assign) BOOL showsFullScreenGallery;

@end

@implementation ImageGalleryViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.imageGalleryView = [[ImageGalleryView alloc] init];
        self.imageGalleryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:self.imageGalleryView];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageGalleryView:)];
        [self.imageGalleryView addGestureRecognizer:tapGestureRecognizer];
    }

    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.imageGalleryView setImagesWithURLStrings:self.imageURLStrings];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageGalleryView cancelImageRequests];
}

- (void)addToParentViewController:(UIViewController *)parentViewController inView:(UIView *)view
{
    [parentViewController addChildViewController:self];
    self.view.frame = view.bounds;
    [view addSubview:self.view];
    [self didMoveToParentViewController:parentViewController];
}

- (void)didTapImageGalleryView:(UITapGestureRecognizer *)sender
{
    if (self.showsFullScreenGallery) {
        [self hideFullScreenGallery];
    } else {
        [self showFullScreenGallery];
    }
    self.showsFullScreenGallery = !self.showsFullScreenGallery;
}

- (void)setFrameColor:(UIColor *)frameColor
{
    self.imageGalleryView.frameColor = frameColor;
}

- (UIColor *)frameColor
{
    return self.imageGalleryView.frameColor;
}

- (void)setFrameWidth:(CGFloat)frameWidth
{
    self.imageGalleryView.frameWidth = frameWidth;
}

- (CGFloat)frameWidth
{
    return self.imageGalleryView.frameWidth;
}

- (void)setSpacing:(CGFloat)spacing
{
    self.imageGalleryView.spacing = spacing;
}

- (CGFloat)spacing
{
    return self.imageGalleryView.spacing;
}

- (void)setClipsToBounds:(BOOL)clipsToBounds
{
    _clipsToBounds = clipsToBounds;
    self.view.clipsToBounds = clipsToBounds;
    self.imageGalleryView.clipsToBounds = clipsToBounds;
}

- (void)showFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.imageGalleryViewSuperView = self.view.superview;
    
    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = UIColor.blackColor;
    self.backgroundView.alpha = 0;
    [windowView addSubview:self.backgroundView];
    [windowView addSubViewAndKeepSamePosition:self.view];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 1;
        self.view.frame = windowView.bounds;
    } completion:NULL];
}

- (void)hideFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    
    // Hack to fix layout after the status bar was hidden
    UIViewController *rootViewController = self.view.window.rootViewController;
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        [navigationController setNavigationBarHidden:YES];
        [navigationController setNavigationBarHidden:NO];
    }
    
    AGWindowView *windowView = [AGWindowView activeWindowViewContainingView:self.view];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 0;
        CGRect frame = [windowView convertRect:self.imageGalleryViewSuperView.bounds fromView:self.imageGalleryViewSuperView];
        self.view.frame = frame;
    } completion:^(BOOL finished) {
        CGRect frame = [self.imageGalleryViewSuperView convertRect:self.view.frame fromView:self.view.superview];
        self.view.frame = frame;
        [self.imageGalleryViewSuperView addSubview:self.view];
        
        [windowView removeFromSuperview];
        self.backgroundView = nil;
    }];
}

@end
