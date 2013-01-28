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
        
        CGRect frame = CGRectMake(0, 0, viewController.view.frame.size.width, viewController.view.frame.size.height);
        self.tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardDidShow:) name:UIKeyboardDidShowNotification object:nil];
        [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)keyboardDidShow:(NSNotification *)notification
{
    NSValue *keyboardFrameAsValue = [notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGRect keyboardFrame = [self.viewController.view convertRect:keyboardFrameAsValue.CGRectValue toView:nil];
    CGRect frame = self.tableView.frame;
    frame.size.height = self.viewController.view.frame.size.height - keyboardFrame.size.height;
    self.tableView.frame = frame;
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
