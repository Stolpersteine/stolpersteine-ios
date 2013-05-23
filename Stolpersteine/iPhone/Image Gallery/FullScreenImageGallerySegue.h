//
//  ViewTransitionSegue.h
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ImageGalleryView;

@interface FullScreenImageGallerySegue : UIStoryboardSegue

@property (nonatomic, strong) UIView *animationView;
@property (nonatomic, strong) ImageGalleryView *imageGalleryView;

@end
