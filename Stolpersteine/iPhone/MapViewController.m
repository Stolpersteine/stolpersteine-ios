//
//  ViewController.m
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

#import "MapViewController.h"

#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "ConfigurationService.h"
#import "Localization.h"

#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinSynchronizationControllerDelegate.h"
#import "StolpersteinSynchronizationController.h"
#import "StolpersteinCardsViewController.h"
#import "StolpersteinAnnotationView.h"
#import "StolpersteinNetworkService.h"

#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterAnnotation.h"

static const double ZOOM_DISTANCE_USER = 1200;
static const double ZOOM_DISTANCE_STOLPERSTEIN = ZOOM_DISTANCE_USER * 0.25;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, UISearchDisplayDelegate, CCHMapClusterControllerDelegate, StolpersteinSynchronizationControllerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, strong) StolpersteinSynchronizationController *stolpersteinSyncController;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) NSArray *searchedStolpersteine;
@property (nonatomic, strong) CCHMapClusterController *mapClusterController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MapViewController.title", nil);
    self.mapView.showsBuildings = YES;
    self.infoButton.accessibilityLabel = NSLocalizedString(@"MapViewController.info", nil);
    
    // Navigation bar
    [self.searchDisplayController.searchBar removeFromSuperview];
    self.searchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.navigationItem.rightBarButtonItem = self.locationBarButtonItem;
    [self updateLocationBarButtonItem];
    self.searchDisplayController.searchBar.placeholder = NSLocalizedString(@"MapViewController.searchBarPlaceholder", nil);
    [self updateSearchBarForInterfaceOrientation:self.interfaceOrientation];
    
    // User location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Clustering
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Start loading data
    self.stolpersteinSyncController = [[StolpersteinSynchronizationController alloc] initWithNetworkService:AppDelegate.networkService];
    self.stolpersteinSyncController.delegate = self;

    // Initialize map region
    self.mapView.region = [AppDelegate.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.mapClusterController.annotations.count < 4600) {
        [self.stolpersteinSyncController synchronize];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];

    // Update data when app becomes active
    [NSNotificationCenter.defaultCenter addObserver:self.stolpersteinSyncController selector:@selector(synchronize) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self.stolpersteinSyncController];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self updateSearchBarForInterfaceOrientation:toInterfaceOrientation];
}

- (void)updateSearchBarForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    UIImage *backgroundImage;
    if (UIDeviceOrientationIsLandscape(interfaceOrientation)) {
        backgroundImage = [UIImage imageNamed:@"SearchBarBackgroundLandscape"];
    } else {
        backgroundImage = [UIImage imageNamed:@"SearchBarBackground"];
    }
    [self.searchDisplayController.searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (void)updateLocationBarButtonItem
{
    UIImage *image;
    NSString *accessibilityLabel;
    if (self.userLocationMode) {
        image = [UIImage imageNamed:@"IconRegion"];
        accessibilityLabel = NSLocalizedString(@"MapViewController.region", nil);
    } else {
        image = [UIImage imageNamed:@"IconLocation"];
        accessibilityLabel = NSLocalizedString(@"MapViewController.location", nil);
    }
    self.locationBarButtonItem.accessibilityLabel = accessibilityLabel;
    [self.locationBarButtonItem setImage:image];
}

- (IBAction)centerMap:(UIBarButtonItem *)sender
{
    BOOL userLocationAvailable = (self.mapView.userLocation.location != nil);
    NSString *diagnosticsLabel;
    if (!self.isUserLocationMode && userLocationAvailable) {
        self.userLocationMode = YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, ZOOM_DISTANCE_USER, ZOOM_DISTANCE_USER);
        [self.mapView setRegion:region animated:YES];
        diagnosticsLabel = @"userLocation";
    } else {
        if (userLocationAvailable) {
            self.userLocationMode = NO;
        }
        MKCoordinateRegion region = [AppDelegate.configurationService coordinateRegionConfigurationForKey:ConfigurationServiceKeyVisibleRegion];
        [self.mapView setRegion:region animated:YES];
        diagnosticsLabel = @"region";
    }
    [self updateLocationBarButtonItem];
    [AppDelegate.diagnosticsService trackEvent:DiagnosticsServiceEventMapCentered withClass:self.class label:diagnosticsLabel];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteineCardsViewController"]) {
        id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
        CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)selectedAnnotation;
        StolpersteinCardsViewController *listViewController = (StolpersteinCardsViewController *)segue.destinationViewController;
        listViewController.stolpersteine = mapClusterAnnotation.annotations.allObjects;
        listViewController.title = [Localization newStolpersteineCountFromCount:mapClusterAnnotation.annotations.count];
    }
}

#pragma mark - Stolperstein synchronization controller

- (void)stolpersteinSynchronizationController:(StolpersteinSynchronizationController *)stolpersteinSynchronizationController didAddStolpersteine:(NSArray *)stolpersteine
{
    [self.mapClusterController addAnnotations:stolpersteine withCompletionHandler:NULL];
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"stolpersteinCluster";
        
        StolpersteinAnnotationView *mapClusterAnnotationView = (StolpersteinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (mapClusterAnnotationView) {
            mapClusterAnnotationView.annotation = annotation;
        } else {
            mapClusterAnnotationView = [[StolpersteinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            mapClusterAnnotationView.canShowCallout = YES;

            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            mapClusterAnnotationView.rightCalloutAccessoryView = rightButton;
        }
        
        CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
        
        annotationView = mapClusterAnnotationView;
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        [self performSegueWithIdentifier:@"mapViewControllerToStolpersteineCardsViewController" sender:self];
    }
}

#pragma mark - Location manager

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        self.mapView.showsUserLocation = YES;
    } else {
        self.mapView.showsUserLocation = NO;
        self.userLocationMode = YES;
        [self updateLocationBarButtonItem];
    }
}

#pragma mark - Search display controller

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(updateSearchData:) withObject:searchString afterDelay:0.3];
    
    return NO;
}

- (void)updateSearchData:(NSString *)searchString
{
    [self.searchStolpersteineOperation cancel];
    
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = searchString;
    self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 100) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.searchedStolpersteine = stolpersteine;
        [self.searchDisplayController.searchResultsTableView reloadData];
        [self.searchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        return YES;
    }];
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setRightBarButtonItem:nil animated:YES];
    [controller.searchBar setShowsCancelButton:YES animated:NO];
}

- (void)searchDisplayControllerDidBeginSearch:(UISearchDisplayController *)controller
{
    [AppDelegate.diagnosticsService trackEvent:DiagnosticsServiceEventSearchStarted withClass:self.class];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.searchStolpersteineOperation cancel];
    [self.navigationItem setRightBarButtonItem:self.locationBarButtonItem animated:YES];
    [controller.searchBar setShowsCancelButton:NO animated:YES];
}

#pragma mark - Map cluster controller

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController titleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newTitleFromMapClusterAnnotation:mapClusterAnnotation];
}

- (NSString *)mapClusterController:(CCHMapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newSubtitleFromMapClusterAnnotation:mapClusterAnnotation];
}

- (void)mapClusterController:(CCHMapClusterController *)mapClusterController willReuseMapClusterAnnotation:(CCHMapClusterAnnotation *)mapClusterAnnotation
{
    StolpersteinAnnotationView *mapClusterAnnotationView = (StolpersteinAnnotationView *)[self.mapClusterController.mapView viewForAnnotation:mapClusterAnnotation];
    mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
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
    self.searchDisplayController.active = NO;
    
    // Force selected annotation to be on map
    Stolperstein *stolperstein = self.searchedStolpersteine[indexPath.row];
    __weak CCHMapClusterController *weakMapClusterController = self.mapClusterController;
    [weakMapClusterController addAnnotations:@[stolperstein] withCompletionHandler:^{
        // Zoom to selected stolperstein
        [weakMapClusterController selectAnnotation:stolperstein andZoomToRegionWithLatitudinalMeters:ZOOM_DISTANCE_STOLPERSTEIN longitudinalMeters:ZOOM_DISTANCE_STOLPERSTEIN];
    }];
}

@end
