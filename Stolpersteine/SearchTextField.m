//
//  SearchTextField.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchTextField.h"

@implementation SearchTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [self setup];
}

- (void)setup
{
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-text-field-magnifier.png"]];
    iconImageView.frame = CGRectMake(0, 0, iconImageView.frame.size.width + 10, iconImageView.frame.size.height);
    iconImageView.contentMode = UIViewContentModeRight;
    self.leftView = iconImageView;
    self.leftViewMode = UITextFieldViewModeAlways;

    self.borderStyle = UITextBorderStyleNone;
    self.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.portraitHeightEnabled = TRUE;
    
    CGRect frame = self.frame;
    frame.size.height = 30;
    self.frame = frame;
}

- (void)setPortraitHeightEnabled:(BOOL)portraitHeightEnabled
{
    UIImage *backgroundImage;
    CGRect frame = self.frame;
    if (portraitHeightEnabled) {
        frame.size.height = 30;
        backgroundImage = [[UIImage imageNamed:@"search-text-field-portrait.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
    } else {
        frame.size.height = 24;
        backgroundImage = [[UIImage imageNamed:@"search-text-field-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
    }
    self.frame = frame;
    self.background = backgroundImage;
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self editingRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect editingRect = [super editingRectForBounds:bounds];
    editingRect.origin.x += 5;
    editingRect.size.width -= 5;
    return editingRect;
}

@end
