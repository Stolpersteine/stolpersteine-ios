//
//  SearchTextField.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
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
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    self.leftViewMode = UITextFieldViewModeAlways;
    self.clearButtonMode = UITextFieldViewModeNever;
    self.borderStyle = UITextBorderStyleNone;
    self.accessibilityTraits = UIAccessibilityTraitSearchField;
    self.portraitModeEnabled = YES;
    self.autocorrectionType = UITextAutocorrectionTypeNo;
    self.returnKeyType = UIReturnKeySearch;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat height = self.portraitModeEnabled ? 30 : 24;
    CGFloat y = roundf((self.superview.frame.size.height - height) * 0.5);
    CGRect frame = CGRectMake(0, y, self.superview.frame.size.width, height);
    self.frame = frame;
}

- (void)setPortraitModeEnabled:(BOOL)portraitModeEnabled
{
    _portraitModeEnabled = portraitModeEnabled;
    
    UIImage *backgroundImage, *iconImage, *clearImage;
    if (portraitModeEnabled) {
        backgroundImage = [[UIImage imageNamed:@"search-text-field-portrait"] resizableImageWithCapInsets:UIEdgeInsetsMake(15, 15, 15, 15)];
        iconImage = [UIImage imageNamed:@"search-text-field-magnifier-portrait"];
        clearImage = [UIImage imageNamed:@"search-text-field-clear-button-portrait"];
    } else {
        backgroundImage = [[UIImage imageNamed:@"search-text-field-landscape"] resizableImageWithCapInsets:UIEdgeInsetsMake(12, 12, 12, 12)];
        iconImage = [UIImage imageNamed:@"search-text-field-magnifier-landscape"];
        clearImage = [UIImage imageNamed:@"search-text-field-clear-button-landscape"];
    }
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
    editingRect.origin.y += self.isPortraitModeEnabled ? 4 : 0;
    editingRect.size.width -= 20;
    return editingRect;
}

- (CGRect)rightViewRectForBounds:(CGRect)bounds
{
    CGRect rightViewRect = [super rightViewRectForBounds:bounds];
    rightViewRect.origin.y -= 1;
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
