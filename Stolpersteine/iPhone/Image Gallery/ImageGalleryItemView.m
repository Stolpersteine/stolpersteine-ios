//
//  ImageGalleryViewCell.m
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
