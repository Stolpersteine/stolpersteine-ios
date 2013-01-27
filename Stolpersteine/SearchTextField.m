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
    self.clearButtonMode = UITextFieldViewModeNever;
    self.borderStyle = UITextBorderStyleNone;
    self.accessibilityTraits = UIAccessibilityTraitSearchField;
    self.portraitModeEnabled = TRUE;
}

- (void)setPortraitModeEnabled:(BOOL)portraitModeEnabled
{
    _portraitModeEnabled = portraitModeEnabled;
    
    UIImage *backgroundImage, *iconImage, *clearImage;
    CGRect frame = self.frame;
    if (portraitModeEnabled) {
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
    iconImageView.frame = CGRectMake(0, 0, iconImageView.frame.size.width, iconImageView.frame.size.height);
    self.leftView = iconImageView;

    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:clearImage forState:UIControlStateNormal];
    clearButton.frame = CGRectMake(0, 0, clearImage.size.width, clearImage.size.height);
    clearButton.accessibilityLabel = @"Clear text";
    [clearButton addTarget:self action:@selector(clearText:) forControlEvents:UIControlEventTouchUpInside];
    self.rightView = clearButton;
    [self bringSubviewToFront:self.rightView];  // needed for VoiceOver to find that button
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return [self editingRectForBounds:bounds];
}

- (CGRect)editingRectForBounds:(CGRect)bounds
{
    CGRect editingRect = [super editingRectForBounds:bounds];
    editingRect.origin.x += 5;
    editingRect.size.width -= 20;
    return editingRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    rightViewRect.origin.x -= 8;
    return rightViewRect;
}

- (CGRect)leftViewRectForBounds:(CGRect)bounds
{
    CGRect leftViewRect = [super leftViewRectForBounds:bounds];
    leftViewRect.origin.x += 10;
    return leftViewRect;
}

- (void)clearText:(UIButton *)sender
{
    BOOL shouldClear = YES;
    if ([self.delegate respondsToSelector:@selector(textFieldShouldClear:)]) {
        shouldClear = [self.delegate textFieldShouldClear:self];
    }
    
    if (shouldClear) {
        self.text = nil;
    }
}

@end
