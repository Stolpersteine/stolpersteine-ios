//
//  ImageScrollView.h
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageGalleryViewDelegate;

@interface ImageGalleryView : UIView

@property (nonatomic, assign, readonly) NSInteger selectedIndex;
@property (nonatomic, weak) id<ImageGalleryViewDelegate> delegate;

- (void)setImagesWithURLs:(NSArray *)urls;
- (void)cancelImageRequests;
- (UIView *)viewForIndex:(NSInteger)index;

@end
