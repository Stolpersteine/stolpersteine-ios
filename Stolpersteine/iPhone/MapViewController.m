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
#import "MapClusteringAnnotation.h"
#import "Localization.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)
static const MKCoordinateRegion BERLIN_REGION = { 52.5233, 13.4127, 0.4493, 0.7366 };
static const double ZOOM_DISTANCE = 1200;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, SearchDisplayDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) SearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSArray *searchedStolpersteine;
@property (nonatomic, strong) Stolperstein *stolpersteinToSelect;
@property (nonatomic, assign) MKCoordinateRegion regionToSet;
@property (nonatomic, assign, getter = isRegionToSetInvalid) BOOL regionToSetInvalid;
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
    NSRange range = NSMakeRange(0, 200);
    [self retrieveStolpersteineWithRange:range];
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
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    self.searchBar.portraitModeEnabled = UIInterfaceOrientationIsPortrait(interfaceOrientation);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (void)retrieveStolpersteineWithRange:(NSRange)range
{
    [self.retrieveStolpersteineOperation cancel];
    self.retrieveStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:nil range:range completionHandler:^(NSArray *stolpersteine, NSError *error) {
        NSLog(@"retrieveStolpersteineWithSearchData %d (%@)", stolpersteine.count, error);
        
        [self.mapClusteringController addAnnotations:stolpersteine];
        
        // Next batch of data
        if (stolpersteine.count == range.length) {
            NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
            [self retrieveStolpersteineWithRange:nextRange];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [self.mapClusteringController updateAnnotationsAnimated:TRUE completion:^{
        if (self.stolpersteinToSelect) {
            MapClusteringAnnotation *annotationToSelect;
            for (MapClusteringAnnotation *annotation in self.mapView.annotations) {
                for (Stolperstein *stolperstein in annotation.stolpersteine) {
                    if ([stolperstein.id isEqualToString:self.stolpersteinToSelect.id]) {
                        annotationToSelect = annotation;
                        break;
                    }
                }
            }

            [mapView selectAnnotation:annotationToSelect animated:YES];
            self.stolpersteinToSelect = nil;
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
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, ZOOM_DISTANCE, ZOOM_DISTANCE);
        [self.mapView setRegion:region animated:YES];
    } else {
        self.userLocationMode = FALSE;
        [self.mapView setRegion:BERLIN_REGION animated:YES];
    }
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
     
    // Check if stolperstein already exists as annotation
    Stolperstein *selectedStolperstein = [self.searchedStolpersteine objectAtIndex:indexPath.row];
    MapClusteringAnnotation *annotationToSelect;
    for (MapClusteringAnnotation *annotation in self.mapView.annotations) {
        for (Stolperstein *stolperstein in annotation.stolpersteine) {
            if ([stolperstein.id isEqualToString:selectedStolperstein.id]) {
                annotationToSelect = annotation;
                break;
            }
        }
    }
    NSLog(@"%@", annotationToSelect);
    
//    // Otherwise, create new annotation
//    if (stolpersteinAnnotationToSelect == nil) {
//        stolpersteinAnnotationToSelect = [[StolpersteinAnnotation alloc] init];
//        stolpersteinAnnotationToSelect.annotations = @[stolperstein];
//    }
    
    // Deselect all annotations
    for (id<MKAnnotation> selectedAnnotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:selectedAnnotation animated:TRUE];
    }
    
    // Center on stolperstein and select it
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(selectedStolperstein.coordinate, ZOOM_DISTANCE * 0.5, ZOOM_DISTANCE * 0.5);
    [self.mapView setRegion:region animated:YES];

    BOOL isRegionUpToDate = fequal(region.center.latitude, self.mapView.region.center.latitude) && fequal(region.center.longitude, self.mapView.region.center.longitude);
    if (isRegionUpToDate) {
        NSLog(@"isRegionUpToDate");
        // Select immediately since region won't change
//        [self.mapView selectAnnotation:stolpersteinAnnotation animated:YES];
    } else {
        NSLog(@"!isRegionUpToDate");
        // Actual selection happens in mapView:regionDidChangeAnimated:
        self.stolpersteinToSelect = selectedStolperstein;
    }
    
    [self.searchDisplayController setActive:FALSE animated:TRUE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
    MapClusteringAnnotation *stolpersteinAnnotation = (MapClusteringAnnotation *)selectedAnnotation;
    if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        detailViewController.stolperstein = [stolpersteinAnnotation.stolpersteine objectAtIndex:0];
    } else if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteineListViewController"]) {
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.stolpersteine = stolpersteinAnnotation.stolpersteine;
        listViewController.title = stolpersteinAnnotation.subtitle;
    }
}

@end
