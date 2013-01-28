//
//  SearchBarViewDelegate.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SearchBarDelegate <NSObject>

@optional
- (void)searchBarTextDidBeginEditing:(SearchBar *)searchBar;
- (void)searchBar:(SearchBar *)searchBar textDidChange:(NSString *)searchText;

@end
