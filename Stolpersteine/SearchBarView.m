//
//  SearchBarView.m
//  Stolpersteine
//
//  Created by Claus on 24.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchBarView.h"

#import "SearchTextField.h"

@interface SearchBarView() <UITextFieldDelegate>

@property (nonatomic, strong) SearchTextField *searchTextField;

@end

@implementation SearchBarView

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
    
    CGRect frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height);
    self.searchTextField = [[SearchTextField alloc] initWithFrame:frame];
    self.searchTextField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.searchTextField.delegate = self;
    self.searchTextField.rightViewMode = UITextFieldViewModeNever;
    [self addSubview:self.searchTextField];
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

@end
