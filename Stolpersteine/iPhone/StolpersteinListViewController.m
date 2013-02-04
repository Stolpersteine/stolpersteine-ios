//
//  StolpersteinListViewController.m
//  Stolpersteine
//
//  Created by Claus on 02.02.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinListViewController.h"

#import "Stolperstein.h"
#import "StolpersteinGroup.h"
#import "StolpersteinDetailViewController.h"

@implementation StolpersteinListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = self.stolpersteinGroup.title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stolpersteinGroup.stolpersteine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    
    Stolperstein *stolperstein = [self.stolpersteinGroup.stolpersteine objectAtIndex:indexPath.row];
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
        Stolperstein *stolperstein = [self.stolpersteinGroup.stolpersteine objectAtIndex:self.tableView.indexPathForSelectedRow.row];
        detailViewController.stolperstein = stolperstein;
    }
}

@end