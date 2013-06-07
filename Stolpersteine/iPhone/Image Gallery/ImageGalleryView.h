//
//  ImageScrollView.h
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageGalleryViewDelegate;

@interface ImageGalleryView : UIScrollView

@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, strong) UIColor *frameColor;
@property (nonatomic, assign) CGFloat spacing;

- (void)setImagesWithURLStrings:(NSArray *)urlStrings;
- (void)cancelImageRequests;
- (UIView *)viewForIndex:(NSInteger)index;

@end
