//
//  ImageGalleryViewController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 06.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageGalleryViewController : UICollectionViewController

@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat frameWidth;
@property (nonatomic, retain) UIColor *frameColor;
@property (nonatomic, retain) NSArray *imageURLStrings;

- (void)addToParentViewController:(UIViewController *)parentViewController inView:(UIView *)view;

@end
