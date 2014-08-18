//
//  StolpersteinCardsCell.h
//  Stolpersteine
//
//  Created by Claus on 19.09.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Stolperstein;
@protocol CCHLinkTextViewDelegate;

@interface StolpersteinCardCell : UITableViewCell

@property (nonatomic, weak) id<CCHLinkTextViewDelegate> linkDelegate;
@property (nonatomic, copy, readonly) Stolperstein *stolperstein;

- (void)updateWithStolperstein:(Stolperstein *)stolperstein linksDisabled:(BOOL)linksDisabled index:(NSUInteger)index;
- (BOOL)canSelectCurrentStolperstein;
- (CGFloat)heightForCurrentStolpersteinWithTableViewWidth:(CGFloat)width;

+ (Stolperstein *)standardStolperstein;

@end
