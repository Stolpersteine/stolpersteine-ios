//
//  SearchBarDisplayController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "SearchDisplayController.h"

#import "SearchBar.h"
#import "SearchDisplayControllerDelegate.h"

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
        self.searchResultsTableView.hidden = YES;
        self.searchResultsTableView.alpha = 0;
        [contentsController.view addSubview:self.searchResultsTableView];
    }
    
    return self;
}

- (void)setBarButtonItemVisible:(BOOL)barButtonItemVisible
{
    UIBarButtonItem *barButtonItem;
    if (barButtonItemVisible) {
        self.barButtonItem = self.searchContentsController.navigationItem.rightBarButtonItem;
        barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    } else {
        barButtonItem = self.barButtonItem;
    }
    
    [self.searchContentsController.navigationItem setRightBarButtonItem:barButtonItem animated:YES];
    
    if ([self.delegate respondsToSelector:@selector(searchDisplayController:willChangeNavigationItem:)]) {
        [self.delegate searchDisplayController:self willChangeNavigationItem:self.searchContentsController.navigationItem];
    }
}

- (void)setSearchResultsTableViewVisible:(BOOL)searchResultsTableViewVisible
{
    [self.searchResultsTableView.layer removeAllAnimations];
    if (searchResultsTableViewVisible) {
        self.searchResultsTableView.hidden = NO;
        [UIView animateWithDuration:0.25 animations:^{
            self.searchResultsTableView.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.25 animations:^{
            self.searchResultsTableView.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                self.searchResultsTableView.hidden = YES;
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
        
        if (active) {
            if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidAppear:)]) {
                [self.delegate searchDisplayControllerDidAppear:self];
            }
        } else {
            [self.searchBar resignFirstResponder];
            if ([self.delegate respondsToSelector:@selector(searchDisplayControllerDidDisappear:)]) {
                [self.delegate searchDisplayControllerDidDisappear:self];
            }
        }
    }
}

- (void)cancel:(UIBarButtonItem *)barButtonItem
{
    self.active = NO;
}

- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar
{
    self.active = YES;
}

- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText
{
    BOOL shouldReloadData = YES;
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
    return YES;
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
