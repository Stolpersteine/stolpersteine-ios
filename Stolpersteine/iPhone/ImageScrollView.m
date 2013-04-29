//
//  ImageScrollView.m
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ImageScrollView.h"

#import "ProgressImageView.h"

#define PADDING 10

@interface ImageScrollView()

@property (strong, nonatomic) NSArray *imageViews;

@end

@implementation ImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.alwaysBounceHorizontal = YES;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.delegate = self;
    }
    return self;
}

- (void)setImagesWithURLs:(NSArray *)urls
{
    NSMutableArray *imageViews = [[NSMutableArray alloc] initWithCapacity:urls.count];
    for (NSURL *url in urls) {
        ProgressImageView *progressImageView = [[ProgressImageView alloc] init];
        progressImageView.backgroundColor = UIColor.grayColor;
        [progressImageView setImageWithURL:url];
        
        [self addSubview:progressImageView];
        [imageViews addObject:progressImageView];
    }
    self.imageViews = imageViews;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    
    CGRect imageFrame = CGRectMake(0, 0, frame.size.height, frame.size.height);
    for (ProgressImageView *progressImageView in self.imageViews) {
        progressImageView.frame = imageFrame;
        imageFrame.origin.x += imageFrame.size.width + PADDING;
    }
    self.contentSize = CGSizeMake(imageFrame.origin.x - PADDING, imageFrame.size.height);
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    NSLog(@"scrollViewWillEndDragging");
}

@end
