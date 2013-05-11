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

#define PADDING 20

@interface ImageGalleryView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *imageViews;
@property (nonatomic, assign) NSInteger indexForSelectedImage;

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
        
        self.indexForSelectedImage = -1;
        
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
    NSMutableArray *imageViews = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (NSURL *url in urls) {
        ProgressImageView *progressImageView = [[ProgressImageView alloc] init];
        progressImageView.frameColor = UIColor.lightGrayColor;
        progressImageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTapImageView:)];
        [progressImageView addGestureRecognizer:tapGestureRecognizer];
        [progressImageView setImageWithURL:url];
        
        [self.scrollView addSubview:progressImageView];
        [imageViews addObject:progressImageView];
    }
    self.imageViews = imageViews;
}

- (void)cancelImageRequests
{
    for (ProgressImageView *progressImageView in self.imageViews) {
        [progressImageView cancelImageRequest];
    }
}

- (UIView *)viewForIndex:(NSInteger)index
{
    UIView *view = nil;
    if (self.imageViews.count > 0 && index >= 0 && index < self.imageViews.count) {
        view = self.imageViews[index];
    }
    
    return view;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect imageFrame = CGRectMake(PADDING, 0, frame.size.height, frame.size.height);
    for (ProgressImageView *progressImageView in self.imageViews) {
        progressImageView.frame = imageFrame;
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
    self.indexForSelectedImage = [self.imageViews indexOfObject:sender.view];
    if ([self.delegate respondsToSelector:@selector(imageScrollView:didSelectImageAtIndex:)]) {
        [self.delegate imageScrollView:self didSelectImageAtIndex:self.indexForSelectedImage];
    }
}

@end
