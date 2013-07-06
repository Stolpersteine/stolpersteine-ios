//
//  DetailViewController.h
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stolperstein;
@class TTTAttributedLabel;
@class RoundedRectButton;

@interface StolpersteinDetailViewController : UIViewController

@property (nonatomic, strong) Stolperstein *stolperstein;
@property (nonatomic, assign, getter = isAllInThisStreetButtonHidden) BOOL allInThisStreetButtonHidden;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *imageGalleryView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet RoundedRectButton *allInThisStreetButton;
@property (weak, nonatomic) IBOutlet RoundedRectButton *biographyButton;
@property (weak, nonatomic) IBOutlet RoundedRectButton *mapsAppButton;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *sourceLabel;

- (IBAction)showActivities:(UIBarButtonItem *)sender;
- (IBAction)showInMapsApp:(UIButton *)sender;

@end
