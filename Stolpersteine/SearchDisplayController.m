//
//  SearchBarDisplayController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchDisplayController.h"

#import "SearchBar.h"
#import "SearchDisplayDelegate.h"

@interface SearchDisplayController()

@property (nonatomic, weak) UIViewController *searchContentsController;
@property (nonatomic, strong) SearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;

@end

static inline UIViewAnimationOptions UIViewAnimationOptionsFromCurve(UIViewAnimationCurve animationCurve)
{
    UIViewAnimationOptions animationOptions;
    
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut: animationOptions = UIViewAnimationOptionCurveEaseInOut; break;
        case UIViewAnimationCurveEaseIn: animationOptions = UIViewAnimationOptionCurveEaseIn; break;
        case UIViewAnimationCurveEaseOut: animationOptions = UIViewAnimationOptionCurveEaseOut; break;
        case UIViewAnimationCurveLinear: animationOptions = UIViewAnimationOptionCurveLinear; break;
        // no default
    }
    
    return animationOptions;
}


@implementation SearchDisplayController

- (id)initWithSearchBar:(SearchBar *)searchBar contentsController:(UIViewController *)contentsController
{
    self = [super init];
    if (self) {
        self.searchBar = searchBar;
        self.searchBar.delegate = self;
        self.searchContentsController = contentsController;
        
        CGRect frame = CGRectMake(0, 0, contentsController.view.frame.size.width, contentsController.view.frame.size.height);
        self.searchResultsTableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.searchResultsTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.searchResultsTableView.hidden = TRUE;
        self.searchResultsTableView.alpha = 0;
        [contentsController.view addSubview:self.searchResultsTableView];
        
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
    CGRect keyboardFrame = [self.searchContentsController.view convertRect:keyboardFrameAsValue.CGRectValue toView:nil];
    NSTimeInterval animationDuration;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionsFromCurve(animationCurve);

    self.searchResultsTableView.hidden = FALSE;
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        CGRect frame = self.searchResultsTableView.frame;
        frame.size.height -= keyboardFrame.size.height;
        self.searchResultsTableView.frame = frame;
        self.searchResultsTableView.alpha = 1;
    } completion:NULL];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSTimeInterval animationDuration;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionsFromCurve(animationCurve);
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        CGRect frame = self.searchResultsTableView.frame;
        frame.size.height = self.searchContentsController.view.frame.size.height;
        self.searchResultsTableView.frame = frame;
        self.searchResultsTableView.alpha = 0;
    } completion:^(BOOL finished) {
        self.searchResultsTableView.hidden = TRUE;
    }];
}

- (void)setActive:(BOOL)active
{
    [self setActive:active animated:NO];
}

- (void)setActive:(BOOL)active animated:(BOOL)animated
{
    _active = active;
    
    UIBarButtonItem *barButtonItem;
    if (active) {
        self.barButtonItem = self.searchContentsController.navigationItem.rightBarButtonItem;
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    } else {
        barButtonItem = self.barButtonItem;
        self.barButtonItem = nil;
    }

    [self.searchContentsController.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (void)cancel:(UIBarButtonItem *)barButtonItem
{
    [self.searchBar resignFirstResponder];
    [self setActive:FALSE animated:TRUE];
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar
{
    [self setActive:TRUE animated:TRUE];
}

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText
{
    BOOL shouldReloadData = TRUE;
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:shouldReloadTableForSearchString:)]) {
        shouldReloadData = [self.delegate searchDisplayController:self shouldReloadTableForSearchString:searchText];
    }
}

@end
