//
//  DetailViewController.h
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stolperstein;
@class ImageGalleryView;

@interface StolpersteinDetailViewController : UIViewController

@property (nonatomic, strong) Stolperstein *stolperstein;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) ImageGalleryView *imageGalleryView;
@property (nonatomic, assign, getter = isAllInThisStreetButtonHidden) BOOL allInThisStreetButtonHidden;

- (IBAction)showActivities:(UIBarButtonItem *)sender;

@end
