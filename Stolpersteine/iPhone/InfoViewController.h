//
//  InfoViewController.h
//  Stolpersteine
//
//  Created by Claus on 26.10.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoViewController : UITableViewController

@property (weak, nonatomic) IBOutlet UILabel *stolpersteineTestLabel;
@property (weak, nonatomic) IBOutlet UIButton *stolpersteineInfoButton;

- (IBAction)showStolpersteineInfo:(UIButton *)sender;
- (IBAction)close:(UIBarButtonItem *)sender;

@end
