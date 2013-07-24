//
//  ImageScrollView.m
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

#import "ImageGalleryView.h"

#import "ProgressImageView.h"
#import "ImageGalleryItemView.h"

@interface ImageGalleryView()<UIScrollViewDelegate>

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
        self.alwaysBounceHorizontal = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.pagingEnabled = YES;
        self.scrollsToTop = NO;
        self.delegate = self;
    }
    return self;
}

- (void)setImagesWithURLStrings:(NSArray *)urlStrings
{
    NSMutableArray *imageGalleryItemViews = [[NSMutableArray alloc] initWithCapacity:urlStrings.count];
    for (NSString *urlString in urlStrings) {
        ImageGalleryItemView *imageGalleryItemView = [[ImageGalleryItemView alloc] init];

        ProgressImageView *progressImageView = imageGalleryItemView.progressImageView;
        progressImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [progressImageView setImageWithURL:[NSURL URLWithString:urlString]];
        
        [self addSubview:imageGalleryItemView];
        [imageGalleryItemViews addObject:imageGalleryItemView];
    }
    self.imageGalleryItemViews = imageGalleryItemViews;
}

- (void)cancelImageRequests
{
    for (ImageGalleryItemView *imageGalleryItemView in self.imageGalleryItemViews) {
        [imageGalleryItemView.progressImageView cancelImageRequest];
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

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect imageFrame;
    CGFloat stepSizeX;
    if (self.showsFullScreenGallery) {
        imageFrame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
        stepSizeX = imageFrame.size.width;
    } else {
        imageFrame = CGRectMake(0, 0, self.frame.size.height, self.frame.size.height);
        stepSizeX = imageFrame.size.width + self.spacing;
    }
    
    for (UIView *view in self.imageGalleryItemViews) {
        view.frame = imageFrame;
        imageFrame.origin.x += stepSizeX;
    }
    self.contentSize = CGSizeMake(imageFrame.origin.x, imageFrame.size.height);
}

@end
