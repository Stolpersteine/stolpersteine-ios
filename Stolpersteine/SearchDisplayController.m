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
        
        CGRect frame = CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height - searchBar.frame.size.height);
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
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
