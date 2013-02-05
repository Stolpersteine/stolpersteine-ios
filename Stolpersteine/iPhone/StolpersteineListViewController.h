//
//  StolpersteinListViewController.h
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@class StolpersteinSearchData;

@interface StolpersteineListViewController : UITableViewController

@property (strong, nonatomic) NSArray *stolpersteine;
@property (strong, nonatomic) StolpersteinSearchData *searchData;

@end
