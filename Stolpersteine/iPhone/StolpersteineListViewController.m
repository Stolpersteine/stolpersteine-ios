//
//  StolpersteinListViewController.m
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteineListViewController.h"

#import "Stolperstein.h"
#import "StolpersteinGroup.h"
#import "StolpersteinDetailViewController.h"

@implementation StolpersteineListViewController

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stolpersteine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Stolperstein *stolperstein = [self.stolpersteine objectAtIndex:indexPath.row];
    cell.textLabel.text = stolperstein.title;
    cell.detailTextLabel.text = stolperstein.subtitle;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:@"stolpersteinListViewControllerToStolpersteinDetailViewController" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinListViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        Stolperstein *stolperstein = [self.stolpersteine objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        detailViewController.stolperstein = stolperstein;
    }
}

@end