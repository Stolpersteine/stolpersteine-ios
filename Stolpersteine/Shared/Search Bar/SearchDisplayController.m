//
//  SearchBarDisplayController.m
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
