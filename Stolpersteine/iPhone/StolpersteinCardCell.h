//
//  StolpersteinCardsCell.h
//  Stolpersteine
//
//  Created by Claus on 19.09.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stolperstein;

@interface StolpersteinCardCell : UITableViewCell

@property (nonatomic, readonly) Stolperstein *stolperstein;

@property (weak, nonatomic) IBOutlet UILabel *bodyLabel;
@property (weak, nonatomic) IBOutlet UIButton *streetButton;
@property (weak, nonatomic) IBOutlet UIButton *sourceButton;

- (void)updateWithStolperstein:(Stolperstein *)stolperstein;
- (CGFloat)estimatedHeight;
- (CGFloat)heightForStolperstein:(Stolperstein *)stolperstein;

- (IBAction)showSource:(UIButton *)sender;

@end
