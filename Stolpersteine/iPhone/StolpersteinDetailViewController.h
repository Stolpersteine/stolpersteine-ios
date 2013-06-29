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

@interface StolpersteinDetailViewController : UIViewController

@property (nonatomic, strong) Stolperstein *stolperstein;

@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *imageGalleryView;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *allInThisStreetButton;
@property (weak, nonatomic) IBOutlet UIButton *biographyButton;
@property (weak, nonatomic) IBOutlet UIButton *mapsAppButton;
@property (strong, nonatomic) IBOutlet TTTAttributedLabel *sourceLabel;

@property (nonatomic, assign, getter = isAllInThisStreetButtonHidden) BOOL allInThisStreetButtonHidden;

- (IBAction)showActivities:(UIBarButtonItem *)sender;
- (IBAction)showAllInThisStreet:(UIButton *)sender;
- (IBAction)showBiography:(UIButton *)sender;
- (IBAction)showInMapsApp:(UIButton *)sender;

@end
