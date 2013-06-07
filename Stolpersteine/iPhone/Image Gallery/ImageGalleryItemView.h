//
//  ImageGalleryViewCell.h
//  Stolpersteine
//
//  Created by Claus on 09.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressImageView;

@interface ImageGalleryItemView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, strong) UIColor *frameColor;  // nil disables frame
@property (nonatomic, strong) ProgressImageView *progressImageView;

@end
