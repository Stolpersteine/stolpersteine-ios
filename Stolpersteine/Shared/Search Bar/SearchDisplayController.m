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

#import <QuartzCore/QuartzCore.h>

@interface SearchDisplayController()

@property (nonatomic, weak) UIViewController *searchContentsController;
@property (nonatomic, strong) SearchBar *searchBar;
@property (nonatomic, strong) UITableView *searchResultsTableView;
@property (nonatomic, strong) UIBarButtonItem *barButtonItem;
@property (nonatomic, assign) CGFloat searchBarPadding;

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
    NSTimeInterval animationDuration;
    [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    UIViewAnimationCurve animationCurve;
    [[notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];
    UIViewAnimationOptions animationOptions = UIViewAnimationOptionsFromCurve(animationCurve);

    CGSize screenSize = UIApplication.sharedApplication.keyWindow.bounds.size;
    CGRect frame = self.searchResultsTableView.frame;
    frame.size.width = screenSize.height;
    self.searchResultsTableView.frame = frame;
    
    [UIView animateWithDuration:animationDuration delay:0.0 options:animationOptions animations:^{
        NSValue *keyboardFrameEndAsValue = [notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
        CGRect keyboardFrameEnd = [self.searchContentsController.view convertRect:keyboardFrameEndAsValue.CGRectValue toView:nil];
        CGRect frame = self.searchResultsTableView.frame;
        frame.size.height -= keyboardFrameEnd.size.height;
        self.searchResultsTableView.frame = frame;
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
    } completion:NULL];
}

- (void)setBarButtonItemVisible:(BOOL)barButtonItemVisible
{
    UIBarButtonItem *barButtonItem;
    if (barButtonItemVisible) {
        self.barButtonItem = self.searchContentsController.navigationItem.rightBarButtonItem;
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.searchBarPadding = self.searchBar.paddingRight;
//        self.searchBar.paddingRight = 75;   // 100
    } else {
        barButtonItem = self.barButtonItem;
        self.barButtonItem = nil;
        self.searchBar.paddingRight = self.searchBarPadding;
    }
    [self.searchContentsController.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
}

- (void)setSearchResultsTableViewVisible:(BOOL)searchResultsTableViewVisible
{
    [self.searchResultsTableView.layer removeAllAnimations];
    if (searchResultsTableViewVisible) {
        self.searchResultsTableView.hidden = FALSE;
        [UIView animateWithDuration:0.25 animations:^{
            self.searchResultsTableView.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.searchResultsTableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.searchResultsTableView.hidden = TRUE;
            }
        }];
    }
}

- (void)setActive:(BOOL)active
{
    if (active != _active) {
        _active = active;
        
        self.barButtonItemVisible = active;
        self.searchResultsTableViewVisible = active;
        if (!active) {
            [self.searchBar resignFirstResponder];
        }
    }
}

- (void)cancel:(UIBarButtonItem *)barButtonItem
{
    self.active = FALSE;
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar
{
    self.active = TRUE;
}

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText
{
    BOOL shouldReloadData = TRUE;
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:shouldReloadTableForSearchString:)]) {
        shouldReloadData = [self.delegate searchDisplayController:self shouldReloadTableForSearchString:searchText];
    }
    
    if (shouldReloadData) {
        [self.searchResultsTableView reloadData];
    }
}

- (BOOL)searchBarShouldReturn:(SearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    return TRUE;
}

- (void)setSearchResultsDataSource:(id<UITableViewDataSource>)searchResultsDataSource
{
    self.searchResultsTableView.dataSource = searchResultsDataSource;
}

- (id<UITableViewDataSource>)searchResultsDataSource
{
    return self.searchResultsDataSource;
}

- (void)setSearchResultsDelegate:(id<UITableViewDelegate>)searchResultsDelegate
{
    self.searchResultsTableView.delegate = searchResultsDelegate;
}

- (id<UITableViewDelegate>)searchResultsDelegate
{
    return self.searchResultsDelegate;
}

@end
