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

- (void)updateWithStolperstein:(Stolperstein *)stolperstein streetButtonHidden:(BOOL)streetButtonHidden index:(NSUInteger)index;
- (void)updateLayoutWithTableView:(UITableView *)tableView;
- (BOOL)canSelectCurrentStolperstein;
- (CGFloat)heightForCurrentStolperstein;

+ (Stolperstein *)standardStolperstein;

@end
