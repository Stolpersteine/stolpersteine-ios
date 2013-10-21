//
//  StolpersteinListViewController.m
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

#import "StolpersteinCardsViewController.h"

#import "Stolperstein.h"
#import "StolpersteinDescriptionViewController.h"
#import "StolpersteinCardCell.h"

#import "AppDelegate.h"
#import "StolpersteinNetworkService.h"
#import "DiagnosticsService.h"
#import "Localization.h"

static NSString * const CELL_IDENTIFIER = @"cell";

@interface StolpersteinCardsViewController()

@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) StolpersteinCardCell *measuringCell;

@end

@implementation StolpersteinCardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.measuringCell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    self.tableView.estimatedRowHeight = [self.measuringCell estimatedHeight];
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contentSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.stolpersteine && self.searchData) {
        [self.searchStolpersteineOperation cancel];
        self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:self.searchData range:NSMakeRange(0, 0) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
            self.stolpersteine = stolpersteine;
            [self.tableView reloadData];
            
            return YES;
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

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
    self.tableView.estimatedRowHeight = [self.measuringCell estimatedHeight];
    [self.tableView reloadData];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinCardsViewControllerToModalStolpersteinCardsViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        UIViewController *cardsViewController = navigationController.topViewController;
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:cardsViewController action:@selector(dismissViewController)];
        cardsViewController.navigationItem.rightBarButtonItem = barButtonItem;
    } else if ([segue.identifier isEqualToString:@"stolpersteinCardsViewControllerToStolpersteinDescriptionViewController"]) {
        StolpersteinCardCell *cardCell = (StolpersteinCardCell *)[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
        Stolperstein *stolperstein = cardCell.stolperstein;
        
        NSURL *url = [[NSURL alloc] initWithString:stolperstein.personBiographyURLString];
        StolpersteinDescriptionViewController *webViewController = (StolpersteinDescriptionViewController *)segue.destinationViewController;
        webViewController.url = url;
        webViewController.title = [Localization newNameFromStolperstein:stolperstein];
    }
}

#pragma mark - Table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.measuringCell heightForStolperstein:self.stolpersteine[indexPath.row]];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stolpersteine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StolpersteinCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    [cell updateWithStolperstein:self.stolpersteine[indexPath.row]];
    
    return cell;
}

@end