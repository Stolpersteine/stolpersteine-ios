//
//  ImageGalleryScrollView.m
//  Stolpersteine
//
//  Created by Claus on 09.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageGalleryScrollView.h"

#import "ProgressImageView.h"

@interface ImageGalleryScrollView()<UIScrollViewDelegate>

@property (nonatomic, strong) ProgressImageView *imageView;

@end

@implementation ImageGalleryScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView = [[ProgressImageView alloc] initWithFrame:frame];
        [self addSubview:self.imageView];
        
        self.delegate = self;
        self.maximumZoomScale = 3.0;
        self.minimumZoomScale = 0.5;
    }
    return self;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    
}

@end
