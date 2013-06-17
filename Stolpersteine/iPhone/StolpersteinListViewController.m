//
//  StolpersteinListViewController.m
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinListViewController.h"

#import "AppDelegate.h"
#import "StolpersteinNetworkService.h"
#import "DiagnosticsService.h"
#import "Stolperstein.h"
#import "StolpersteinDetailViewController.h"
#import "Localization.h"

@interface StolpersteinListViewController()

@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;

@end

@implementation StolpersteinListViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.stolpersteine) {
        [self.searchStolpersteineOperation cancel];
        self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:self.searchData range:NSMakeRange(0, 0) completionHandler:^(NSArray *stolpersteine, NSError *error) {
            self.stolpersteine = stolpersteine;
            [self.tableView reloadData];
        }];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.searchStolpersteineOperation cancel];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stolpersteine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Stolperstein *stolperstein = self.stolpersteine[indexPath.row];
    cell.textLabel.text = [Localization newNameFromStolperstein:stolperstein];
    cell.detailTextLabel.text = [Localization newShortAddressFromStolperstein:stolperstein];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"stolpersteineListViewControllerToStolpersteinDetailViewController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteineListViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        Stolperstein *stolperstein = self.stolpersteine[self.tableView.indexPathForSelectedRow.row];
        detailViewController.stolperstein = stolperstein;
        
        if (self.searchData) {
            // Stop endless navigation
            detailViewController.allInThisStreetButtonHidden = YES;
        }
    }
}

@end