//
//  DetailViewController.h
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stolperstein;

@interface DetailViewController : UIViewController

@property (nonatomic, strong) Stolperstein *stolperstein;

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *imageActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@end
