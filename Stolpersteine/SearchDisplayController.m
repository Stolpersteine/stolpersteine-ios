//
//  SearchBarDisplayController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchDisplayController.h"

#import "SearchBar.h"

@interface SearchDisplayController()

@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, strong) SearchBar *searchBar;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SearchDisplayController

- (id)initWithSearchBar:(SearchBar *)searchBar contentsController:(UIViewController *)viewController
{
    self = [super init];
    if (self) {
        self.searchBar = searchBar;
        self.viewController = viewController;
        
        CGRect frame = CGRectMake(0, 0, self.viewController.view.frame.size.width, self.viewController.view.frame.size.height);
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.tableView.hidden = TRUE;
        self.tableView.alpha = 0;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSValue *keyboardFrameAsValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardFrame = [self.viewController.view convertRect:keyboardFrameAsValue.CGRectValue toView:nil];
    NSTimeInterval animationDuration;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    UIViewAnimationOptions animationOptions;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            animationOptions = UIViewAnimationOptionCurveEaseInOut;
        case UIViewAnimationCurveEaseIn:
            animationOptions = UIViewAnimationOptionCurveEaseIn;
        case UIViewAnimationCurveEaseOut:
            animationOptions = UIViewAnimationOptionCurveEaseOut;
        case UIViewAnimationCurveLinear:
            animationOptions = UIViewAnimationOptionCurveLinear;
        // no default
    }

    self.tableView.hidden = FALSE;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        CGRect frame = self.tableView.frame;
        frame.size.height -= keyboardFrame.size.height;
        self.tableView.frame = frame;
        self.tableView.alpha = 1;
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    CGRect frame = self.tableView.frame;
    frame.size.height = self.viewController.view.frame.size.height;
    self.tableView.frame = frame;
}

- (void)setActive:(BOOL)active animated:(BOOL)animated
{
    self.active = active;
    
    if (active) {
        [self.viewController.view addSubview:self.tableView];
    } else {
        [self.tableView removeFromSuperview];
    }
}

@end
