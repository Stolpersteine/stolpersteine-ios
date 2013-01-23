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
    self.leftViewMode = UITextFieldViewModeAlways;
    self.rightViewMode = UITextFieldViewModeAlways;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.borderStyle = UITextBorderStyleNone;
    self.portraitHeightEnabled = TRUE;
}

- (void)setPortraitHeightEnabled:(BOOL)portraitHeightEnabled
{
    UIImage *backgroundImage, *iconImage, *clearImage;
    CGRect frame = self.frame;
    if (portraitHeightEnabled) {
        frame.size.height = 30;
        backgroundImage = [[UIImage imageNamed:@"search-text-field-portrait.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        iconImage = [UIImage imageNamed:@"search-text-field-magnifier-portrait.png"];
        clearImage = [UIImage imageNamed:@"search-text-field-clear-button-portrait.png"];
    } else {
        frame.size.height = 24;
        backgroundImage = [[UIImage imageNamed:@"search-text-field-landscape.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        iconImage = [UIImage imageNamed:@"search-text-field-magnifier-landscape.png"];
        clearImage = [UIImage imageNamed:@"search-text-field-clear-button-landscape.png"];
    }
    
    self.frame = frame;
    self.background = backgroundImage;
    
    UIImageView *iconImageView = [[UIImageView alloc] initWithImage:iconImage];
    iconImageView.frame = CGRectMake(0, 0, iconImageView.frame.size.width + 10, iconImageView.frame.size.height);
    iconImageView.contentMode = UIViewContentModeRight;
    self.leftView = iconImageView;

    UIImageView *clearImageView = [[UIImageView alloc] initWithImage:clearImage];
    clearImageView.frame = CGRectMake(0, 0, clearImageView.frame.size.width + 6, clearImageView.frame.size.height);
    clearImageView.contentMode = UIViewContentModeLeft;
    self.rightView = clearImageView;
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
