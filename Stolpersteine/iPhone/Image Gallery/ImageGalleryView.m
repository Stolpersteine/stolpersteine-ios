//
//  ImageScrollView.m
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryView.h"

#import "ProgressImageView.h"
#import "ImageGalleryItemView.h"
#import "AGWindowView.h"

#define PADDING 20
#define ANIMATION_DURATION 0.3f
#define FRAME_COLOR UIColor.lightGrayColor

@interface ImageGalleryView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageGalleryItemViews;

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
    self.scrollView.contentOffset = CGPointZero;
}

- (void)setImagesWithURLs:(NSArray *)urls
{
    NSMutableArray *imageGalleryItemViews = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (NSURL *url in urls) {
        ImageGalleryItemView *imageGalleryItemView = [[ImageGalleryItemView alloc] init];
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        [imageGalleryItemView addGestureRecognizer:tapGestureRecognizer];

        ProgressImageView *progressImageView = imageGalleryItemView.imageView;
        progressImageView.frameColor = FRAME_COLOR;
        [progressImageView setImageWithURL:url];
        
        [self.scrollView addSubview:imageGalleryItemView];
        [imageGalleryItemViews addObject:imageGalleryItemView];
    }
    self.imageGalleryItemViews = imageGalleryItemViews;
}

- (void)cancelImageRequests
{
    for (ImageGalleryItemView *imageGalleryItemView in self.imageGalleryItemViews) {
        [imageGalleryItemView.imageView cancelImageRequest];
    }
}

- (UIView *)viewForIndex:(NSInteger)index
{
    UIView *view = nil;
    if (self.imageGalleryItemViews.count > 0 && index >= 0 && index < self.imageGalleryItemViews.count) {
        view = self.imageGalleryItemViews[index];
    }
    
    return view;
}

- (void)setFrameColor:(UIColor *)color
{
    for (ImageGalleryItemView *imageGalleryItemView in self.imageGalleryItemViews) {
        imageGalleryItemView.imageView.frameColor = color;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame;
    CGFloat stepSizeX;
    if (self.showsFullScreenGallery) {
        imageFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        stepSizeX = imageFrame.size.width;
    } else {
        imageFrame = CGRectMake(PADDING, 0, self.frame.size.height, self.frame.size.height);
        stepSizeX = imageFrame.size.width + PADDING;
    }
    
    for (UIView *imageView in self.imageGalleryItemViews) {
        imageView.frame = imageFrame;
        imageFrame.origin.x += stepSizeX;
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
    self.scrollView.pagingEnabled = YES;
    
    AGWindowView *windowView = [[AGWindowView alloc] initAndAddToKeyWindow];
    windowView.supportedInterfaceOrientations = UIInterfaceOrientationMaskAll;
    self.backgroundView = [[UIView alloc] initWithFrame:windowView.bounds];
    self.backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundView.backgroundColor = UIColor.blackColor;
    self.backgroundView.alpha = 0;
    [windowView addSubview:self.backgroundView];
    [windowView addSubViewAndKeepSamePosition:self];
    
    [UIView animateWithDuration:ANIMATION_DURATION animations:^{
        [self setFrameColor:nil];
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
        [self setFrameColor:FRAME_COLOR];
        self.backgroundView.alpha = 0;
        CGRect frame = [windowView convertRect:self.imageGalleryViewSuperView.bounds fromView:self.imageGalleryViewSuperView];
        self.frame = frame;
    } completion:^(BOOL finished) {
        CGRect frame = [self.imageGalleryViewSuperView convertRect:self.frame fromView:self.superview];
        self.frame = frame;
        [self.imageGalleryViewSuperView addSubview:self];
        
        [windowView removeFromSuperview];
        self.backgroundView = nil;
        self.scrollView.pagingEnabled = NO;
    }];
}

@end
