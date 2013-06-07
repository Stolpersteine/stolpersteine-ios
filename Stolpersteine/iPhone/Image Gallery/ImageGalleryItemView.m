//
//  ImageGalleryViewCell.m
//  Stolpersteine
//
//  Created by Claus on 09.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryItemView.h"

#import "ProgressImageView.h"
#import <QuartzCore/QuartzCore.h>

@implementation ImageGalleryItemView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.progressImageView = [[ProgressImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.progressImageView];
        
        self.scrollsToTop = NO;
        self.delegate = self;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 0.5;
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
    UIColor *frameColor = [UIColor colorWithCGColor:self.layer.borderColor];
    CGFloat white, alpha;
    [frameColor getWhite:&white alpha:&alpha];
    if (white == 0 && alpha == 0) {
        frameColor = nil;
    }
    
    return frameColor;
}

@end
