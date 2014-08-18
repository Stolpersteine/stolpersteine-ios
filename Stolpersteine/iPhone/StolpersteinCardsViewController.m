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
#import "StolpersteineSearchData.h"
#import "StolpersteineNetworkService.h"

#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"

#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "Localization.h"

static NSString * const CELL_IDENTIFIER = @"cell";

@interface StolpersteinCardsViewController () <CCHLinkTextViewDelegate>

@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic) StolpersteinCardCell *measuringCell;

@end

@implementation StolpersteinCardsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    StolpersteinCardCell *measuringCell = [self.tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    [measuringCell updateWithStolperstein:StolpersteinCardCell.standardStolperstein linksDisabled:self.linksDisabled index:0];
    CGFloat width = self.tableView.frame.size.width;
    self.tableView.estimatedRowHeight = [measuringCell heightForCurrentStolpersteinWithTableViewWidth:width];
    self.measuringCell = measuringCell;
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(contentSizeCategoryDidChange:) name:UIContentSizeCategoryDidChangeNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (!self.stolpersteine && self.searchData) {
        [self.searchStolpersteineOperation cancel];
        self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:self.searchData range:NSMakeRange(0, 0) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
            self.stolpersteine = stolpersteine;
            self.title = self.searchData.street;
            [self.tableView reloadData];
            
            return NO;
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
    
    // Make sure that menu controller on table cell gets hidden
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setMenuVisible:NO animated:YES];
    
    [self.searchStolpersteineOperation cancel];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // To make sure table cells have correct height
    [self.tableView reloadData];
}

- (BOOL)linksDisabled
{
    return (self.searchData != nil);
}

- (void)contentSizeCategoryDidChange:(NSNotification *)notification
{
    [self.measuringCell updateWithStolperstein:StolpersteinCardCell.standardStolperstein linksDisabled:self.linksDisabled index:0];
    CGFloat width = self.tableView.frame.size.width;
    self.tableView.estimatedRowHeight = [self.measuringCell heightForCurrentStolpersteinWithTableViewWidth:width];
    [self.tableView reloadData];
}

- (void)dismissViewController
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    NSIndexPath *indexPath;
    if ([sender isKindOfClass:CCHLinkTextView.class]) {
        UIView *view = (UIView *)sender;
        CGPoint point = [self.tableView convertPoint:view.center fromView:view];
        indexPath = [self.tableView indexPathForRowAtPoint:point];
    } else {
        indexPath = self.tableView.indexPathForSelectedRow;
    }
    
    StolpersteinCardCell *cardCell = (StolpersteinCardCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    Stolperstein *stolperstein = cardCell.stolperstein;

    if ([segue.identifier isEqualToString:@"stolpersteinCardsViewControllerToStolpersteinCardsViewController"]) {
        UINavigationController *navigationController = segue.destinationViewController;
        StolpersteinCardsViewController *cardsViewController = (StolpersteinCardsViewController *)navigationController.topViewController;
        UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:cardsViewController action:@selector(dismissViewController)];
        cardsViewController.navigationItem.rightBarButtonItem = barButtonItem;
        
        NSString *street = street = [Localization newStreetNameFromStolperstein:stolperstein];
        StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:nil street:street city:nil];
        cardsViewController.searchData = searchData;
    } else if ([segue.identifier isEqualToString:@"stolpersteinCardsViewControllerToStolpersteinDescriptionViewController"]) {
        StolpersteinDescriptionViewController *webViewController = (StolpersteinDescriptionViewController *)segue.destinationViewController;
        webViewController.stolperstein = stolperstein;
        webViewController.title = [Localization newNameFromStolperstein:stolperstein];
    }
}

#pragma mark - Table view

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.measuringCell updateWithStolperstein:self.stolpersteine[indexPath.row] linksDisabled:self.linksDisabled index:0];
    CGFloat width = self.tableView.frame.size.width;
    CGFloat height = [self.measuringCell heightForCurrentStolpersteinWithTableViewWidth:width];
    return height;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.stolpersteine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    StolpersteinCardCell *cell = [tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER forIndexPath:indexPath];
    cell.linkDelegate = self;
    [cell updateWithStolperstein:self.stolpersteine[indexPath.row] linksDisabled:self.linksDisabled index:indexPath.row];
    
    if ([cell canSelectCurrentStolperstein]) {
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    } else {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StolpersteinCardCell *cardCell = (StolpersteinCardCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    if ([cardCell canSelectCurrentStolperstein]) {
        [self performSegueWithIdentifier:@"stolpersteinCardsViewControllerToStolpersteinDescriptionViewController" sender:self];
    }
}

#pragma mark Link handling

- (void)linkTextView:(CCHLinkTextView *)linkTextView didTapLinkWithValue:(id)value
{
    [self performSegueWithIdentifier:@"stolpersteinCardsViewControllerToStolpersteinCardsViewController" sender:linkTextView];
}

- (void)linkTextView:(CCHLinkTextView *)linkTextView didLongPressLinkWithValue:(id)value
{
    [self performSegueWithIdentifier:@"stolpersteinCardsViewControllerToStolpersteinCardsViewController" sender:linkTextView];
}

@end