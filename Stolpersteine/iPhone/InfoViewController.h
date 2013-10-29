//
//  InfoViewController.h
//  Stolpersteine
//
//  Created by Claus on 26.10.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *stolpersteineLabel;
@property (weak, nonatomic) IBOutlet UIButton *stolpersteineInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *artistInfoButton;

@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;

@property (weak, nonatomic) IBOutlet UILabel *sourcesLabel;
@property (weak, nonatomic) IBOutlet UIButton *kssButton;
@property (weak, nonatomic) IBOutlet UIButton *wikipediaButton;

@property (weak, nonatomic) IBOutlet UILabel *acknowledgementsLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *gitHubButton;

@property (weak, nonatomic) IBOutlet UILabel *legalLabel;

- (IBAction)close:(UIBarButtonItem *)sender;

@end
