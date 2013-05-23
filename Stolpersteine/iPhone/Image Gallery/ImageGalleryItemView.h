//
//  ImageGalleryScrollView.h
//  Stolpersteine
//
//  Created by Claus on 09.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ProgressImageView;

@interface ImageGalleryItemView : UIScrollView

@property (nonatomic, strong) ProgressImageView *imageView;

@end
