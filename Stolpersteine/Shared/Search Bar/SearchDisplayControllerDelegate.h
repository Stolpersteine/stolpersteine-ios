//
//  SearchDisplayDelegate.h
//  Stolpersteine
//
//  Created by Claus on 28.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchDisplayController;

@protocol SearchDisplayControllerDelegate <NSObject>

@optional
- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString;
- (void)searchDisplayController:(SearchDisplayController *)controller willChangeNavigationItem:(UINavigationItem *)navigationItem;
- (void)searchDisplayControllerDidAppear:(SearchDisplayController *)controller;
- (void)searchDisplayControllerDidDisappear:(SearchDisplayController *)controller;

@end
