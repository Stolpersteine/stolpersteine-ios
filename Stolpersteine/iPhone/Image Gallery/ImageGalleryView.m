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
        imageGalleryItemView.frameWidth = self.frameWidth;
        imageGalleryItemView.frameColor = self.frameColor;

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
