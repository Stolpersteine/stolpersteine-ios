//
//  ImageScrollViewDelegate.h
//  Stolpersteine
//
//  Created by Claus on 30.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class ImageGalleryView;

@protocol ImageGalleryViewDelegate <NSObject>

@optional
- (void)imageScrollView:(ImageGalleryView *)imageScrollView didSelectImageAtIndex:(NSInteger)index;

@end
