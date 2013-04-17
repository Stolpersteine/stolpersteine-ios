//
//  SearchBarView.m
//  Stolpersteine
//
//  Created by Claus on 24.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchBar.h"

#import "SearchTextField.h"
#import "SearchBarDelegate.h"

#define PADDING_LEFT 5

@interface SearchBar() <UITextFieldDelegate>

@property (nonatomic, strong) SearchTextField *searchTextField;

@end

@implementation SearchBar

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
    self.backgroundColor = UIColor.clearColor;
    
    self.searchTextField = [[SearchTextField alloc] initWithFrame:CGRectZero];  // text field automatically resizes to fit
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    self.searchTextField.delegate = self;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self addSubview:self.searchTextField];
    
    [self.searchTextField addTarget:self action:@selector(editingDidBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [self.searchTextField addTarget:self action:@selector(editingChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)setText:(NSString *)text
{
    self.searchTextField.text = text;
}

- (NSString *)text
{
    return self.searchTextField.text;
}

- (void)setFrame:(CGRect)frame
{
    // Hack to avoid wrong width when changing the orientation while the search
    // bar is not visible.
    CGFloat y = (self.superview.frame.size.height - self.frame.size.height) * 0.5;
    [super setFrame:CGRectMake(PADDING_LEFT, y, self.superview.frame.size.width - self.paddingRight, frame.size.height)];
}

- (void)setPortraitModeEnabled:(BOOL)portraitModeEnabled
{
    self.searchTextField.portraitModeEnabled = portraitModeEnabled;
}

- (BOOL)isPortraitModeEnabled
{
    return self.searchTextField.isPortraitModeEnabled;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    textField.rightViewMode = UITextFieldViewModeNever;
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *text = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.rightViewMode = text.length > 0 ? UITextFieldViewModeAlways : UITextFieldViewModeNever;
    
    return TRUE;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL result = TRUE;
    if ([self.delegate respondsToSelector:@selector(searchBarShouldReturn:)]) {
        result = [self.delegate searchBarShouldReturn:self];
    }
    
    return result;
}

- (void)editingDidBegin:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBarTextDidBeginEditing:)]) {
        [self.delegate searchBarTextDidBeginEditing:self];
    }
}

- (void)editingChanged:(UITextField *)textField
{
    if ([self.delegate respondsToSelector:@selector(searchBar:textDidChange:)]) {
        [self.delegate searchBar:self textDidChange:textField.text];
    }
}

- (BOOL)resignFirstResponder
{
    [super resignFirstResponder];
    return [self.searchTextField resignFirstResponder];
}

@end
