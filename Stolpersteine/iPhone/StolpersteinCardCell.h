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
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (void)updateWithStolperstein:(Stolperstein *)stolperstein;

+ (CGFloat)standardHeight;
+ (CGFloat)heightForStolperstein:(Stolperstein *)stolperstein;

@end
