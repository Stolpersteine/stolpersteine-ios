//
//  ImageGalleryViewController.m
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

#import "ImageGalleryViewController.h"

#import "ProgressImageView.h"
#import "ImageGalleryView.h"
#import "ImageGalleryItemView.h"
//#import "AGWindowView.h"

#define ITEM_IDENTIFIER @"item"
#define ANIMATION_DURATION 0.3f

@interface ImageGalleryViewController()<UIScrollViewDelegate>

@property (nonatomic, strong) ImageGalleryView *imageGalleryView;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imageGalleryViewSuperView;
@property (nonatomic, assign) BOOL showsFullScreenGallery;

@end

@implementation ImageGalleryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageGalleryView = [[ImageGalleryView alloc] init];
    self.imageGalleryView.spacing = self.spacing;
    self.imageGalleryView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.imageGalleryView];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageGalleryView:)];
    [self.imageGalleryView addGestureRecognizer:tapGestureRecognizer];
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

- (void)setSpacing:(CGFloat)spacing
{
    _spacing = spacing;
    self.imageGalleryView.spacing = spacing;
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
    
//    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
//    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
//    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
//    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.backgroundView.backgroundColor = UIColor.blackColor;
//    self.backgroundView.alpha = 0;
//    [windowView addSubview:self.backgroundView];
//    [windowView addSubViewAndKeepSamePosition:self.view];
//    
//    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//        self.backgroundView.alpha = 1;
//        self.view.frame = windowView.bounds;
//    } completion:NULL];
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
    
//    AGWindowView *windowView = [AGWindowView activeWindowViewContainingView:self.view];
//    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
//        self.backgroundView.alpha = 0;
//        CGRect frame = [windowView convertRect:self.imageGalleryViewSuperView.bounds fromView:self.imageGalleryViewSuperView];
//        self.view.frame = frame;
//    } completion:^(BOOL finished) {
//        CGRect frame = [self.imageGalleryViewSuperView convertRect:self.view.frame fromView:self.view.superview];
//        self.view.frame = frame;
//        [self.imageGalleryViewSuperView addSubview:self.view];
//        
//        [windowView removeFromSuperview];
//        self.backgroundView = nil;
//    }];
}

@end
