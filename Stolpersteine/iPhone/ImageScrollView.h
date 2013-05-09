//
//  ImageScrollView.h
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDelegate;

@interface ImageScrollView : UIView

@property (nonatomic, assign, readonly) NSInteger indexForSelectedImage;
@property (nonatomic, weak) id<ImageScrollViewDelegate> imageScrollViewDelegate;

- (void)setImagesWithURLs:(NSArray *)urls;
- (void)cancelImageRequests;
- (UIView *)viewForIndex:(NSInteger)index;

@end
