//
//  ViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapViewController.h"

#import "AppDelegate.h"
#import "StolpersteinNetworkService.h"
#import "DiagnosticsService.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinDetailViewController.h"
#import "StolpersteinListViewController.h"
#import "SearchBar.h"
#import "SearchDisplayController.h"
#import "SearchDisplayDelegate.h"
#import "MapClusteringController.h"
#import "MapClusteringControllerDelegate.h"
#import "MapClusteringAnnotation.h"
#import "Localization.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
static const MKCoordinateRegion BERLIN_REGION = { 52.5233, 13.4127, 0.4493, 0.7366 };
static const double ZOOM_DISTANCE_USER = 1200;
static const double ZOOM_DISTANCE_STOLPERSTEIN = ZOOM_DISTANCE_USER * 0.25;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, SearchDisplayDelegate, MapClusteringControllerDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) SearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSArray *searchedStolpersteine;
@property (nonatomic, strong) Stolperstein *stolpersteinToSelect;
@property (nonatomic, strong) MapClusteringAnnotation *annotationToSelect;
@property (nonatomic, assign) MKCoordinateRegion regionToSet;
@property (nonatomic, assign, getter = isRegionToSetInvalid) BOOL regionToSetInvalid;
@property (nonatomic, assign) MKCoordinateSpan regionSpanBeforeChange;
@property (nonatomic, strong) MapClusteringController *mapClusteringController;

@end

@implementation MapViewController

@synthesize searchDisplayController;    // Duplicates original property with new type

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MapViewController.title", nil);
    
    // Search bar
    self.searchDisplayController = [[SearchDisplayController alloc] initWithSearchBar:self.searchBar contentsController:self];
    self.searchDisplayController.delegate = self;
    self.searchDisplayController.searchResultsDataSource = self;
    self.searchDisplayController.searchResultsDelegate = self;
    UIBarButtonItem *barButtonItem = self.navigationItem.rightBarButtonItem;
    NSString *homeBarButtonItemTitle = NSLocalizedString(@"MapViewController.home", nil);
    NSString *cancelBarButtonItemTitle = NSLocalizedString(@"MapViewController.cancel", nil);
    barButtonItem.possibleTitles = [NSSet setWithArray:@[homeBarButtonItemTitle, cancelBarButtonItemTitle]];
    barButtonItem.title = homeBarButtonItemTitle;
    self.navigationItem.rightBarButtonItem = nil;   // forces possible titles to take effect
    self.navigationItem.rightBarButtonItem = barButtonItem;
    CGFloat paddingRight = NSLocalizedString(@"MapViewController.searchBarPaddingRight", nil).floatValue;
    self.searchBar.paddingRight = paddingRight;
    
    // User location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    // Initialize map region
    self.regionToSet = BERLIN_REGION;
    
    // Clustering
    self.mapClusteringController = [[MapClusteringController alloc] initWithMapView:self.mapView];
    self.mapClusteringController.delegate = self;
    
    // Imprint link
    NSString *imprint = NSLocalizedString(@"MapViewController.imprint", nil);
    NSMutableAttributedString *attributedString = [[self.imprintButton attributedTitleForState:UIControlStateNormal] mutableCopy];
    attributedString.mutableString.string = imprint;
    [attributedString addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(0, attributedString.length)];
    [self.imprintButton setAttributedTitle:attributedString forState:UIControlStateNormal];
    
    // Start loading data
    [self retrieveStolpersteine];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Region is restored here to avoid problems when setting this property
    // while the map is off screen.
    if (!self.isRegionToSetInvalid) {
        self.mapView.region = self.regionToSet;
        self.regionToSetInvalid = TRUE;
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewController:self];

    // Update data when app becomes active
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(retrieveStolpersteine) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.searchBar.portraitModeEnabled = UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)retrieveStolpersteine
{
    NSRange range = NSMakeRange(0, 500);
    [self retrieveStolpersteineWithRange:range];
}

- (void)retrieveStolpersteineWithRange:(NSRange)range
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:nil range:range completionHandler:^(NSArray *stolpersteine, NSError *error) {
        [self.mapClusteringController addAnnotations:stolpersteine];
        
        // Next batch of data
        if (stolpersteine.count == range.length) {
            NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
            [self retrieveStolpersteineWithRange:nextRange];
        }
    }];
}

- (id<MKAnnotation>)annotationForStolperstein:(Stolperstein *)stolperstein inMapRect:(MKMapRect)mapRect
{
    id<MKAnnotation> annotationResult = nil;
    
    NSSet *annotations = [self.mapView annotationsInMapRect:mapRect];
    for (id<MKAnnotation> annotation in annotations) {
        if ([annotation isKindOfClass:MapClusteringAnnotation.class]) {
            MapClusteringAnnotation *clusteringAnnotation = (MapClusteringAnnotation *)annotation;
            NSUInteger index = [clusteringAnnotation.annotations indexOfObject:stolperstein];
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
        [self.mapView deselectAnnotation:selectedAnnotation animated:TRUE];
    }
}

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
    [self.mapClusteringController updateAnnotationsAnimated:TRUE completion:^{
        if (self.stolpersteinToSelect) {
            // Map has zoomed to selected stolperstein; search for cluster annotation that contains this stolperstein
            id<MKAnnotation> annotation = [self annotationForStolperstein:self.stolpersteinToSelect inMapRect:mapView.visibleMapRect];
            self.stolpersteinToSelect = nil;
            
            // Dispatch async to avoid calling regionDidChangeAnimated immediately
            dispatch_async(dispatch_get_main_queue(), ^{
                // No zooming, only panning. Otherwise, stolperstein might change to a different cluster annotation
                [self.mapView setCenterCoordinate:annotation.coordinate animated:FALSE];
            });
            
            if ([self isCoordinateUpToDate:annotation.coordinate]) {
                // Select immediately since region won't change
                [self.mapView selectAnnotation:annotation animated:YES];
            } else {
                // Actual selection happens in next call to mapView:regionDidChangeAnimated:
                self.annotationToSelect = annotation;
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
    
    if ([annotation isKindOfClass:MapClusteringAnnotation.class]) {
        static NSString *stolpersteinIdentifier = @"stolpersteinIdentifier";
        
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:stolpersteinIdentifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stolpersteinIdentifier];
            pinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            annotationView = pinView;
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
    if ([view.annotation isKindOfClass:MapClusteringAnnotation.class]) {
        MapClusteringAnnotation *stolpersteinAnnotation = (MapClusteringAnnotation *)view.annotation;
        NSString *identifier;
        if (stolpersteinAnnotation.isCluster) {
            identifier = @"mapViewControllerToStolpersteineListViewController";
        } else {
            identifier = @"mapViewControllerToStolpersteinDetailViewController";
        }
        
        [self performSegueWithIdentifier:identifier sender:view.annotation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        self.mapView.showsUserLocation = TRUE;
    } else {
        self.userLocation = nil;
        self.mapView.showsUserLocation = FALSE;
    }
}

- (IBAction)centerMap:(UIButton *)sender
{
    if (!self.isUserLocationMode && self.userLocation.location) {
        self.userLocationMode = TRUE;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, ZOOM_DISTANCE_USER, ZOOM_DISTANCE_USER);
        [self.mapView setRegion:region animated:YES];
    } else {
        self.userLocationMode = FALSE;
        [self.mapView setRegion:BERLIN_REGION animated:YES];
    }
}

- (IBAction)showImprint:(UIButton *)sender
{
    NSString *imprintURLAsString = NSLocalizedString(@"MapViewController.imprintURL", nil);
    NSURL *url = [NSURL URLWithString:imprintURLAsString];
    [UIApplication.sharedApplication openURL:url];
}

- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchStolpersteineOperation cancel];
    
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = searchString;
    self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 100) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        self.searchedStolpersteine = stolpersteine;
        [self.searchDisplayController.searchResultsTableView reloadData];
    }];
                                           
    return FALSE;
}

- (NSString *)mapClusteringController:(MapClusteringController *)mapClusteringController titleForClusterAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation
{
    NSString *title;
    if (mapClusteringAnnotation.isCluster) {
        NSUInteger numStolpersteine = MIN(mapClusteringAnnotation.annotations.count, 5);
        NSArray *stolpersteine = [mapClusteringAnnotation.annotations subarrayWithRange:NSMakeRange(0, numStolpersteine)];
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:numStolpersteine];
        for (Stolperstein *stolperstein in stolpersteine) {
            [names addObject:[Localization newShortNameFromStolperstein:stolperstein]];
        }
        title = [names componentsJoinedByString:@", "];
    } else {
        Stolperstein *stolperstein = mapClusteringAnnotation.annotations[0];
        title = [Localization newNameFromStolperstein:stolperstein];
    }
    
    return title;
}

- (NSString *)mapClusteringController:(MapClusteringController *)mapClusteringController subtitleForClusterAnnotation:(MapClusteringAnnotation *)mapClusteringAnnotation
{
    NSString *subtitle;
    if (mapClusteringAnnotation.isCluster) {
        subtitle = [NSString stringWithFormat:@"%u Stolpersteine", mapClusteringAnnotation.annotations.count];
    } else {
        Stolperstein *stolperstein = mapClusteringAnnotation.annotations[0];
        subtitle = [Localization newShortAddressFromStolperstein:stolperstein];
    }
    
    return subtitle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    Stolperstein *stolperstein = [self.searchedStolpersteine objectAtIndex:indexPath.row];
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
    UITableViewCell *tableViewCell = [tableView cellForRowAtIndexPath:indexPath];
    [tableViewCell setSelected:FALSE animated:TRUE];
     
    // Deselect annotations
    [self deselectAllAnnotations];

    // Force selected stolperstein to be on map
    self.stolpersteinToSelect = [self.searchedStolpersteine objectAtIndex:indexPath.row];
    [self.mapClusteringController addAnnotations:@[self.stolpersteinToSelect]];

    // Zoom in to selected stolperstein
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.stolpersteinToSelect.coordinate, ZOOM_DISTANCE_STOLPERSTEIN, ZOOM_DISTANCE_STOLPERSTEIN);
    [self.mapView setRegion:region animated:YES];
    if ([self isCoordinateUpToDate:region.center]) {
        // Manually call update methods because region won't change
        [self mapView:self.mapView regionWillChangeAnimated:TRUE];
        [self mapView:self.mapView regionDidChangeAnimated:TRUE];
    }
    
    // Dismiss search display controller
    self.searchDisplayController.active = FALSE;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
    MapClusteringAnnotation *clusteringAnnotation = (MapClusteringAnnotation *)selectedAnnotation;
    if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        detailViewController.stolperstein = clusteringAnnotation.annotations[0];
    } else if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteineListViewController"]) {
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.stolpersteine = clusteringAnnotation.annotations;
        listViewController.title = clusteringAnnotation.subtitle;
    }
}

@end
