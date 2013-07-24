//
//  SearchBarDisplayController.h
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
