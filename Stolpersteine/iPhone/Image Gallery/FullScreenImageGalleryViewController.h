//
//  FullScreenImagGalleryViewController.h
//  Stolpersteine
//
//  Created by Claus on 30.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageGalleryView;

@interface FullScreenImageGalleryViewController : UIViewController

@property (nonatomic, strong) ImageGalleryView *imageGalleryView;
@property (nonatomic, copy) void (^completionBlock)();

@end
