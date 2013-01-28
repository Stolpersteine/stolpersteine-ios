//
//  SearchBarDisplayController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchBar;

@interface SearchDisplayController : NSObject

@property (nonatomic, assign, getter = isActive) BOOL active;

- (id)initWithSearchBar:(SearchBar *)searchBar contentsController:(UIViewController *)viewController;
- (void)setActive:(BOOL)active animated:(BOOL)animated;

@end
