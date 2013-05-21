//
//  SearchBarDisplayController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "SearchBarDelegate.h"

@class SearchBar;
@protocol SearchDisplayControllerDelegate;

@interface SearchDisplayController : NSObject<SearchBarDelegate>

@property (nonatomic, assign, getter = isActive) BOOL active;
@property (nonatomic, weak) NSObject<SearchDisplayControllerDelegate> *delegate;
@property (nonatomic, readonly, strong) SearchBar *searchBar;
@property (nonatomic, readonly) UIViewController *searchContentsController;
@property (nonatomic, weak) id<UITableViewDataSource> searchResultsDataSource;
@property (nonatomic, weak) id<UITableViewDelegate> searchResultsDelegate;
@property (nonatomic, readonly, strong) UITableView *searchResultsTableView;

- (id)initWithSearchBar:(SearchBar *)searchBar contentsController:(UIViewController *)viewController;
- (void)setActive:(BOOL)active;

@end
