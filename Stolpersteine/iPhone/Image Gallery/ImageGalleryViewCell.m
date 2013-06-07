//
//  ImageGalleryViewCell.m
//  Stolpersteine
//
//  Created by Claus on 09.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryViewCell.h"

#import "ProgressImageView.h"
#import <QuartzCore/QuartzCore.h>

@interface ImageGalleryViewCell()<UIScrollViewDelegate>

@property (nonatomic, retain) UIScrollView *scrollView;

@end

@implementation ImageGalleryViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        CGRect bounds = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        self.scrollView = [[UIScrollView alloc] initWithFrame:bounds];
        self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.scrollView.scrollsToTop = NO;
        self.scrollView.delegate = self;
        self.scrollView.maximumZoomScale = 3.0;
        self.scrollView.minimumZoomScale = 0.5;
        [self.contentView addSubview:self.scrollView];
        
        self.frameWidth = 1;
        self.frameColor = nil;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.progressImageView;
}

- (void)setFrameWidth:(CGFloat)frameWidth
{
    self.layer.borderWidth = frameWidth;
}

- (CGFloat)frameWidth
{
    return self.layer.borderWidth;
}

- (void)setFrameColor:(UIColor *)frameColor
{
    if (frameColor == nil) {
        frameColor = [UIColor colorWithWhite:0 alpha:0];
    }
    self.layer.borderColor = frameColor.CGColor;
}

- (UIColor *)frameColor
{
    UIColor *frameColor = [UIColor colorWithCGColor:self.contentView.layer.borderColor];
    CGFloat white, alpha;
    [frameColor getWhite:&white alpha:&alpha];
    if (white == 0 && alpha == 0) {
        frameColor = nil;
    }
    
    return frameColor;
}

- (void)setProgressImageView:(ProgressImageView *)progressImageView
{
    [_progressImageView removeFromSuperview];
    _progressImageView = progressImageView;
    
    progressImageView.frame = self.bounds;
    progressImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.scrollView addSubview:progressImageView];
}

@end
