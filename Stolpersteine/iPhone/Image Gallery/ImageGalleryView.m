//
//  ImageScrollView.m
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryView.h"

#import "ProgressImageView.h"
#import "ImageGalleryViewDelegate.h"
#import "ImageGalleryItemView.h"
#import "AGWindowView.h"

#define PADDING 20
#define ANIMATION_DURATION 0.3f

@interface ImageGalleryView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageGalleryScrollViews;
@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) UIView *imageGalleryViewSuperView;
@property (nonatomic, assign) BOOL showsFullScreenGallery;

@end

@implementation ImageGalleryView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.showsHorizontalScrollIndicator = NO;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        [self addSubview:self.scrollView];
        
        self.selectedIndex = -1;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(scrollToTop) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)scrollToTop
{
    [self.scrollView setContentOffset:CGPointZero animated:NO];
}

- (void)setImagesWithURLs:(NSArray *)urls
{
    NSMutableArray *scrollViews = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (NSURL *url in urls) {
        ImageGalleryItemView *imageGalleryScrollView = [[ImageGalleryItemView alloc] init];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        [imageGalleryScrollView addGestureRecognizer:tapGestureRecognizer];

        ProgressImageView *progressImageView = imageGalleryScrollView.imageView;
        progressImageView.frameColor = UIColor.lightGrayColor;
        [progressImageView setImageWithURL:url];
        
        [self.scrollView addSubview:imageGalleryScrollView];
        [scrollViews addObject:imageGalleryScrollView];
    }
    self.imageGalleryScrollViews = scrollViews;
}

- (void)cancelImageRequests
{
    for (ImageGalleryItemView *scrollView in self.imageGalleryScrollViews) {
        [scrollView.imageView cancelImageRequest];
    }
}

- (UIView *)viewForIndex:(NSInteger)index
{
    UIView *view = nil;
    if (self.imageGalleryScrollViews.count > 0 && index >= 0 && index < self.imageGalleryScrollViews.count) {
        view = self.imageGalleryScrollViews[index];
    }
    
    return view;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame = CGRectMake(PADDING, 0, self.frame.size.height, self.frame.size.height);
    for (UIView *imageView in self.imageGalleryScrollViews) {
        imageView.frame = imageFrame;
        imageFrame.origin.x += imageFrame.size.width + PADDING;
    }
    self.scrollView.contentSize = CGSizeMake(imageFrame.origin.x, imageFrame.size.height);
}

- (CGFloat)offsetForTargetOffset:(CGFloat)targetOffset
{
    // Snap to image views
    CGFloat offset = targetOffset;
    if ((self.scrollView.contentSize.width - targetOffset) > self.frame.size.width) {
        CGFloat pageWidth = self.frame.size.height + PADDING;
        CGFloat remainder = fmod(targetOffset, pageWidth);
        CGFloat guidedOffsetX;
        if (remainder < (self.frame.size.height * 0.5 + PADDING)) {
            guidedOffsetX = targetOffset - remainder;
        } else {
            guidedOffsetX = targetOffset - remainder + pageWidth;
        }
        offset = guidedOffsetX;
    }
    
    return offset;
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    targetContentOffset->x = [self offsetForTargetOffset:targetContentOffset->x];
}

- (void)didTapImageView:(UITapGestureRecognizer *)sender
{
    self.selectedIndex = [self.imageGalleryScrollViews indexOfObject:sender.view];
//    if ([self.delegate respondsToSelector:@selector(imageScrollView:didSelectImageAtIndex:)]) {
//        [self.delegate imageScrollView:self didSelectImageAtIndex:self.selectedIndex];
//    }
    
    if (self.showsFullScreenGallery) {
        [self hideFullScreenGallery];
    } else {
        [self showFullScreenGallery];
    }
    self.showsFullScreenGallery = !self.showsFullScreenGallery;
}

- (void)showFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    self.imageGalleryViewSuperView = self.superview;
    
    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = UIColor.blackColor;
    self.backgroundView.alpha = 0;
    [windowView addSubview:self.backgroundView];
    [windowView addSubViewAndKeepSamePosition:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 1;
        self.frame = windowView.bounds;
    } completion:NULL];
}

- (void)hideFullScreenGallery
{
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];

    // Hack to fix layout after the status bar was hidden
    UIViewController *rootViewController = self.window.rootViewController;
    if ([rootViewController isKindOfClass:UINavigationController.class]) {
        UINavigationController *navigationController = (UINavigationController *)rootViewController;
        [navigationController setNavigationBarHidden:YES];
        [navigationController setNavigationBarHidden:NO];
    }
    
    AGWindowView *windowView = [AGWindowView activeWindowViewContainingView:self];
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        self.backgroundView.alpha = 0;
        CGRect frame = [windowView convertRect:self.imageGalleryViewSuperView.bounds fromView:self.imageGalleryViewSuperView];
        self.frame = frame;
    } completion:^(BOOL finished) {
        CGRect frame = [self.imageGalleryViewSuperView convertRect:self.frame fromView:self.superview];
        self.frame = frame;
        [self.imageGalleryViewSuperView addSubview:self];
        
        [windowView removeFromSuperview];
        self.backgroundView = nil;
    }];
}

@end
