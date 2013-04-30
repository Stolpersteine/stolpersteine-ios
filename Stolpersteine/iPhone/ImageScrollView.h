//
//  ImageScrollView.h
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImageScrollViewDelegate;

@interface ImageScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, weak) id<ImageScrollViewDelegate> imageScrollViewDelegate;

- (void)setImagesWithURLs:(NSArray *)urls;
- (void)cancelImageRequests;

@end
