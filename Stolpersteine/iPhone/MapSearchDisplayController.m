//
//  MapSearchDisplayController.m
//  Stolpersteine
//
//  Copyright (C) 2014 Option-U Software
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

#import "MapSearchDisplayController.h"

#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "Localization.h"

#import "Stolperstein.h"
#import "StolpersteineSearchData.h"
#import "StolpersteineNetworkService.h"

#import "CCHMapClusterController.h"

#define REQUEST_DELAY 0.3
#define REQUEST_SIZE 100

@interface MapSearchDisplayController()

@property (nonatomic, copy) NSArray *searchedStolpersteine;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, weak) UIBarButtonItem *originalBarButtonItem;

@end

@implementation MapSearchDisplayController

#pragma mark - Search display controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(updateSearchData:) withObject:searchString afterDelay:REQUEST_DELAY];
    
    return NO;
}

- (void)updateSearchData:(NSString *)searchString
{
    [self.searchStolpersteineOperation cancel];
    
    StolpersteineSearchData *searchData = [[StolpersteineSearchData alloc] initWithKeywordsString:searchString street:nil city:nil];
    self.searchStolpersteineOperation = [self.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, REQUEST_SIZE) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.searchedStolpersteine = stolpersteine;
        [self.searchResultsTableView reloadData];
        [self.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        return NO;
    }];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    self.originalBarButtonItem = controller.navigationItem.rightBarButtonItem;
    [controller.navigationItem setRightBarButtonItem:nil animated:YES];
    [controller.searchBar setShowsCancelButton:YES animated:NO];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [AppDelegate.diagnosticsService trackEvent:DiagnosticsServiceEventSearchStarted withClass:self.class];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchStolpersteineOperation cancel];
    [controller.navigationItem setRightBarButtonItem:self.originalBarButtonItem animated:YES];
    [controller.searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    Stolperstein *stolperstein = self.searchedStolpersteine[indexPath.row];
    cell.textLabel.text = [Localization newNameFromStolperstein:stolperstein];
    cell.detailTextLabel.text = [Localization newShortAddressFromStolperstein:stolperstein];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.searchedStolpersteine.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Deselect table row
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // Dismiss search display controller
    self.active = NO;
    
    // Force selected annotation to be on map
    Stolperstein *stolperstein = self.searchedStolpersteine[indexPath.row];
    __weak CCHMapClusterController *weakMapClusterController = self.mapClusterController;
    [weakMapClusterController addAnnotations:@[stolperstein] withCompletionHandler:^{
        // Zoom to selected stolperstein
        [weakMapClusterController selectAnnotation:stolperstein andZoomToRegionWithLatitudinalMeters:self.zoomDistance longitudinalMeters:self.zoomDistance];
    }];
}

@end
