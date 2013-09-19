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
#import "StolpersteinNetworkService.h"
#import "DiagnosticsService.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinSynchronizationControllerDelegate.h"
#import "StolpersteinSynchronizationController.h"
#import "StolpersteinDetailViewController.h"
#import "StolpersteinCardsViewController.h"
#import "SearchBar.h"
#import "SearchDisplayController.h"
#import "SearchDisplayControllerDelegate.h"
#import "MapClusterController.h"
#import "MapClusterControllerDelegate.h"
#import "MapClusterAnnotation.h"
#import "Localization.h"

#define fequal(a, b) (fabs((a) - (b)) < FLT_EPSILON)
static const MKCoordinateRegion BERLIN_REGION = { {52.5233, 13.4127}, {0.4493, 0.7366} };
static const double ZOOM_DISTANCE_USER = 1200;
static const double ZOOM_DISTANCE_STOLPERSTEIN = ZOOM_DISTANCE_USER * 0.25;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, SearchDisplayControllerDelegate, MapClusterControllerDelegate, StolpersteinSynchronizationControllerDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, strong) StolpersteinSynchronizationController *stolpersteinSyncController;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) SearchDisplayController *mySearchDisplayController;
@property (nonatomic, strong) NSArray *searchedStolpersteine;
@property (nonatomic, strong) Stolperstein *stolpersteinToSelect;
@property (nonatomic, strong) MapClusterAnnotation *annotationToSelect;
@property (nonatomic, assign) MKCoordinateRegion regionToSet;
@property (nonatomic, assign, getter = isRegionToSetInvalid) BOOL regionToSetInvalid;
@property (nonatomic, assign) MKCoordinateSpan regionSpanBeforeChange;
@property (nonatomic, strong) MapClusterController *mapClusterController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MapViewController.title", nil);
    
    // Search bar
    self.searchBar.placeholder = NSLocalizedString(@"MapViewController.searchBarPlaceholder", nil);
    self.mySearchDisplayController = [[SearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.mySearchDisplayController.delegate = self;
    self.mySearchDisplayController.searchResultsDataSource = self;
    self.mySearchDisplayController.searchResultsDelegate = self;

    // Navigation bar
    self.locationButton = [[UIButton alloc] init];
    [self.locationButton addTarget:self action:@selector(centerMap:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem.customView = self.locationButton;
    
    // User location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Initialize map region
    self.regionToSet = BERLIN_REGION;
    
    // Clustering
    self.mapClusterController = [[MapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Imprint link
    NSString *imprint = NSLocalizedString(@"MapViewController.imprint", nil);
    NSMutableAttributedString *attributedString = [[self.imprintButton attributedTitleForState:UIControlStateNormal] mutableCopy];
    attributedString.mutableString.string = imprint;
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, attributedString.length)];
    [self.imprintButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    // Start loading data
    self.stolpersteinSyncController = [[StolpersteinSynchronizationController alloc] initWithNetworkService:AppDelegate.networkService];
    self.stolpersteinSyncController.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if (self.mapClusterController.numberOfAnnotations < 4600) {
        [self.stolpersteinSyncController synchronize];
    }
    
    // Region is restored here to avoid problems when setting this property
    // while the map is off screen.
    if (!self.isRegionToSetInvalid) {
        self.mapView.region = self.regionToSet;
        self.regionToSetInvalid = YES;
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
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

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.searchBar.portraitModeEnabled = UIInterfaceOrientationIsPortrait(interfaceOrientation);
    [self layoutNavigationBarButtonsForInterfaceOrientation:interfaceOrientation animated:NO];
}

- (void)layoutNavigationBarButtonsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation animated:(BOOL)animated
{
    UIImage *image, *backgroundImage;
    CGRect frame = self.locationButton.frame;
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        if (self.userLocationMode) {
            image = [UIImage imageNamed:@"icon-region-landscape.png"];
        } else {
            image = [UIImage imageNamed:@"icon-location-landscape.png"];
        }
        frame.size = CGSizeMake(24, 24);
        backgroundImage = [UIImage imageNamed:@"bar-button-landscape.png"];
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(15, 5, 15, 5)];
    } else {
        if (self.userLocationMode) {
            image = [UIImage imageNamed:@"icon-region-portrait.png"];
        } else {
            image = [UIImage imageNamed:@"icon-location-portrait.png"];
        }
        frame.size = CGSizeMake(30, 30);
        backgroundImage = [UIImage imageNamed:@"bar-button-portrait.png"];
        backgroundImage = [backgroundImage resizableImageWithCapInsets:UIEdgeInsetsMake(12, 4, 12, 4)];
    }
    [self.locationButton setImage:image forState:UIControlStateNormal];
    self.locationButton.frame = frame;
    [self.locationButton setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    // Hack to avoid wrong width when changing the orientation while the search bar is not visible.
    if (self.navigationItem.rightBarButtonItem.customView == self.locationButton) {
        self.searchBar.paddingRight = frame.size.width + 15;
    } else {
        NSString *paddingRightAsString = NSLocalizedString(@"MapViewController.paddingRight", nil);
        self.searchBar.paddingRight = paddingRightAsString.floatValue;
    }
    
    void (^changeUI)() = ^() {
        self.searchBar.frame = self.searchBar.frame;
    };
    if (animated) {
        [UIView animateWithDuration:0.25 animations:changeUI];
    } else {
        changeUI();
    }
}

- (id<MKAnnotation>)annotationForStolperstein:(Stolperstein *)stolperstein inMapRect:(MKMapRect)mapRect
{
    id<MKAnnotation> annotationResult = nil;
    
    NSSet *annotations = [self.mapView annotationsInMapRect:mapRect];
    for (id<MKAnnotation> annotation in annotations) {
        if ([annotation isKindOfClass:MapClusterAnnotation.class]) {
            MapClusterAnnotation *mapClusterAnnotation = (MapClusterAnnotation *)annotation;
            NSUInteger index = [mapClusterAnnotation.annotations indexOfObject:stolperstein];
            if (index != NSNotFound) {
                annotationResult = annotation;
                break;
            }
        }
    }
    
    return annotationResult;
}

- (BOOL)isCoordinateUpToDate:(CLLocationCoordinate2D)coordinate
{
    BOOL isCoordinateUpToDate = fequal(coordinate.latitude, self.mapView.region.center.latitude) && fequal(coordinate.longitude, self.mapView.region.center.longitude);
    return isCoordinateUpToDate;
}

- (void)deselectAllAnnotations
{
    NSArray *selectedAnnotations = self.mapView.selectedAnnotations;
    for (id<MKAnnotation> selectedAnnotation in selectedAnnotations) {
        [self.mapView deselectAnnotation:selectedAnnotation animated:YES];
    }
}

- (IBAction)centerMap:(UIButton *)sender
{
    if (!self.isUserLocationMode && self.userLocation.location) {
        self.userLocationMode = YES;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, ZOOM_DISTANCE_USER, ZOOM_DISTANCE_USER);
        [self.mapView setRegion:region animated:YES];
    } else {
        if (self.userLocation.location) {
            self.userLocationMode = NO;
        }
        [self.mapView setRegion:BERLIN_REGION animated:YES];
    }
    [self layoutNavigationBarButtonsForInterfaceOrientation:self.interfaceOrientation animated:NO];
}

- (IBAction)showImprint:(UIButton *)sender
{
    NSString *imprintURLAsString = NSLocalizedString(@"MapViewController.imprintURL", nil);
    NSURL *url = [NSURL URLWithString:imprintURLAsString];
    [UIApplication.sharedApplication openURL:url];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
    MapClusterAnnotation *mapClusterAnnotation = (MapClusterAnnotation *)selectedAnnotation;
    if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        detailViewController.stolperstein = mapClusterAnnotation.annotations[0];
    } else if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteineListViewController"]) {
        StolpersteinCardsViewController *listViewController = (StolpersteinCardsViewController *)segue.destinationViewController;
        listViewController.stolpersteine = mapClusterAnnotation.annotations;
        listViewController.title = [Localization newStolpersteineCountFromMapClusterAnnotation:mapClusterAnnotation];
    }
}

#pragma mark - Stolpersteine synchronization controller

- (void)stolpersteinSynchronizationController:(StolpersteinSynchronizationController *)stolpersteinSynchronizationController didAddStolpersteine:(NSArray *)stolpersteine
{
    [self.mapClusterController addAnnotations:stolpersteine];   
}

#pragma mark - Map view

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
    self.regionSpanBeforeChange = mapView.region.span;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    // Deselect all annotations when zooming in/out. Longitude delta will not change
    // unless zoom changes (in contrast to latitude delta).
    BOOL hasZoomed = !fequal(mapView.region.span.longitudeDelta, self.regionSpanBeforeChange.longitudeDelta);
    if (hasZoomed) {
        [self deselectAllAnnotations];
    }

    // Update annotations
    [self.mapClusterController updateAnnotationsWithCompletionHandler:^{
        if (self.stolpersteinToSelect) {
            // Map has zoomed to selected stolperstein; search for cluster annotation that contains this stolperstein
            id<MKAnnotation> annotation = [self annotationForStolperstein:self.stolpersteinToSelect inMapRect:mapView.visibleMapRect];
            self.stolpersteinToSelect = nil;
            
            if ([self isCoordinateUpToDate:annotation.coordinate]) {
                // Select immediately since region won't change
                [self.mapView selectAnnotation:annotation animated:YES];
            } else {
                // Actual selection happens in next call to mapView:regionDidChangeAnimated:
                self.annotationToSelect = annotation;
                
                // Dispatch async to avoid calling regionDidChangeAnimated immediately
                dispatch_async(dispatch_get_main_queue(), ^{
                    // No zooming, only panning. Otherwise, stolperstein might change to a different cluster annotation
                    [self.mapView setCenterCoordinate:annotation.coordinate animated:NO];
                });
            }
        } else if (self.annotationToSelect) {
            // Map has zoomed to annotation
            [self.mapView selectAnnotation:self.annotationToSelect animated:YES];
            self.annotationToSelect = nil;
        }
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:MapClusterAnnotation.class]) {
        static NSString *stolpersteinIdentifier = @"stolpersteinIdentifier";
        
        annotationView = (MKAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:stolpersteinIdentifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stolpersteinIdentifier];
            annotationView.canShowCallout = YES;
            annotationView.image = [UIImage imageNamed:@"stolperstein-single.png"];

            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            annotationView.rightCalloutAccessoryView = rightButton;
        }
    }
    
    return annotationView;
}

- (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id<MKOverlay>)overlay
{
    MKOverlayView *view;
    if ([overlay isKindOfClass:MKPolygon.class]) {
        MKPolygonView *polygonView = [[MKPolygonView alloc] initWithPolygon:(MKPolygon *)overlay];
        polygonView.strokeColor = [UIColor.blueColor colorWithAlphaComponent:0.7];
        polygonView.lineWidth = 1;
        view = polygonView;
    }
    
    return view;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLocation = userLocation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if ([view.annotation isKindOfClass:MapClusterAnnotation.class]) {
        MapClusterAnnotation *mapClusterAnnotation = (MapClusterAnnotation *)view.annotation;
        NSString *identifier;
        if (mapClusterAnnotation.isCluster) {
            identifier = @"mapViewControllerToStolpersteineListViewController";
        } else {
            identifier = @"mapViewControllerToStolpersteinDetailViewController";
        }
        
        [self performSegueWithIdentifier:identifier sender:view.annotation];
    }
}

#pragma mark - Location manager

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        self.mapView.showsUserLocation = YES;
    } else {
        self.userLocation = nil;
        self.mapView.showsUserLocation = NO;
        self.userLocationMode = YES;
        [self layoutNavigationBarButtonsForInterfaceOrientation:self.interfaceOrientation animated:NO];
    }
}

#pragma mark - Search display controller

- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchStolpersteineOperation cancel];
    
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = searchString;
    self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 100) completionHandler:^BOOL(NSArray *stolpersteine, NSError *error) {
        self.searchedStolpersteine = stolpersteine;
        [self.mySearchDisplayController.searchResultsTableView reloadData];
        [self.mySearchDisplayController.searchResultsTableView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        
        return YES;
    }];
                                           
    return NO;
}

- (void)searchDisplayController:(SearchDisplayController *)controller willChangeNavigationItem:(UINavigationItem *)navigationItem
{
    [self layoutNavigationBarButtonsForInterfaceOrientation:self.interfaceOrientation animated:YES];
}

- (void)searchDisplayControllerDidAppear:(SearchDisplayController *)controller
{
    [AppDelegate.diagnosticsService trackViewWithClass:self.mySearchDisplayController.class];
}

- (void)searchDisplayControllerDidDisappear:(SearchDisplayController *)controller
{
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

#pragma mark - Map cluster controller

- (NSString *)mapClusterController:(MapClusterController *)mapClusterController titleForMapClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newTitleFromMapClusterAnnotation:mapClusterAnnotation];
}

- (NSString *)mapClusterController:(MapClusterController *)mapClusterController subtitleForMapClusterAnnotation:(MapClusterAnnotation *)mapClusterAnnotation
{
    return [Localization newSubtitleFromMapClusterAnnotation:mapClusterAnnotation];
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
     
    // Deselect annotations
    [self deselectAllAnnotations];

    // Force selected stolperstein to be on map
    self.stolpersteinToSelect = self.searchedStolpersteine[indexPath.row];
    [self.mapClusterController addAnnotations:@[self.stolpersteinToSelect]];

    // Zoom in to selected stolperstein
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.stolpersteinToSelect.coordinate, ZOOM_DISTANCE_STOLPERSTEIN, ZOOM_DISTANCE_STOLPERSTEIN);
    [self.mapView setRegion:region animated:YES];
    if ([self isCoordinateUpToDate:region.center]) {
        // Manually call update methods because region won't change
        [self mapView:self.mapView regionWillChangeAnimated:YES];
        [self mapView:self.mapView regionDidChangeAnimated:YES];
    }
    
    // Dismiss search display controller
    self.mySearchDisplayController.active = NO;
}

#pragma mark - Scroll view

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self.searchBar resignFirstResponder];
}

@end
