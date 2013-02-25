//
//  ViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapViewController.h"

#import "AppDelegate.h"
#import "StolpersteineNetworkService.h"
#import "Stolperstein.h"
#import "StolpersteinAnnotation.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinDetailViewController.h"
#import "StolpersteineListViewController.h"
#import "SearchBar.h"
#import "SearchDisplayController.h"
#import "SearchDisplayDelegate.h"
#import "MapClusteringController.h"
#import "Localization.h"

#define fequal(a,b) (fabs((a) - (b)) < FLT_EPSILON)

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDataSource, UITableViewDelegate, SearchDisplayDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;
@property (nonatomic, weak) NSOperation *retrieveStolpersteineOperation;
@property (nonatomic, weak) NSOperation *searchStolpersteineOperation;
@property (nonatomic, strong) SearchDisplayController *searchDisplayController;
@property (nonatomic, strong) NSArray *searchedStolpersteine;
@property (nonatomic, strong) StolpersteinAnnotation *stolpersteinAnnotationToSelect;
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
    
    // Set map location to Berlin
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.5233, 13.4127);
    self.regionToSet = MKCoordinateRegionMakeWithDistance(location, 12000, 12000);
    
    // Clustering
    self.mapClusteringController = [[MapClusteringController alloc] initWithMapView:self.mapView];
    NSRange range = NSMakeRange(0, 500);
    [self retrieveStolpersteineWithRange:range];
}

- (void)viewDidUnload
{
    self.locationManager.delegate = nil;

    [self setMapView:nil];
    [self setCenterMapBarButtonItem:nil];
    [self setSearchBar:nil];
    
    [super viewDidUnload];
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
        
        [self.mapClusteringController addStolpersteine:stolpersteine];
        
        // Next batch of data
        if (stolpersteine.count == range.length) {
            NSRange nextRange = NSMakeRange(NSMaxRange(range), range.length);
            [self retrieveStolpersteineWithRange:nextRange];
        }

        if (stolpersteine.count > 0) {
//            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@", Stolperstein.class];
//            NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
//            
//            // Annotations to be removed
//            NSArray *stolpersteineIds = [stolpersteine valueForKey:@"id"];
//            predicate = [NSPredicate predicateWithFormat:@"NOT (id IN %@)", stolpersteineIds];
//            NSArray *annotationsToRemove = [annotations filteredArrayUsingPredicate:predicate];
//            [self.mapView removeAnnotations:annotationsToRemove];
//            
//            // New annotations
//            NSArray *annotationIds = [annotations valueForKey:@"id"];
//            predicate = [NSPredicate predicateWithFormat:@"NOT (id IN %@)", annotationIds];
//            NSArray *annotationsToAdd = [stolpersteine filteredArrayUsingPredicate:predicate];
//            [self.mapView addAnnotations:annotationsToAdd];
//            
//            NSLog(@"%d added, %d removed", annotationsToAdd.count, annotationsToRemove.count);
//            [self.mapView addAnnotations:stolpersteine];
        }
    }];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    if (self.stolpersteinAnnotationToSelect) {
        [mapView selectAnnotation:self.stolpersteinAnnotationToSelect animated:YES];
        self.stolpersteinAnnotationToSelect = nil;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AnnotationsAdded" object:self];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:StolpersteinAnnotation.class]) {
        static NSString *stolpersteinIdentifier = @"stolpersteinIdentifier";
        
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:stolpersteinIdentifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stolpersteinIdentifier];
//            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            pinView.rightCalloutAccessoryView = rightButton;
            
            annotationView = pinView;
        }
    }
    
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
    self.userLocation = userLocation;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    NSString *identifier;
    if ([view.annotation isKindOfClass:StolpersteinAnnotation.class]) {
        identifier = @"mapViewControllerToStolpersteinDetailViewController";
    } else {
        identifier = @"mapViewControllerToStolpersteineListViewController";
    }
    [self performSegueWithIdentifier:identifier sender:view.annotation];
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
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, 1200, 1200);
        [self.mapView setRegion:region animated:YES];
    } else {
        self.userLocationMode = FALSE;
        MKMapRect zoomRect = MKMapRectNull;
        for (id<MKAnnotation> annotation in self.mapView.annotations) {
            if (annotation != self.mapView.userLocation) {
                MKMapPoint annotationPoint = MKMapPointForCoordinate(annotation.coordinate);
                MKMapRect pointRect = MKMapRectMake(annotationPoint.x, annotationPoint.y, 0.1, 0.1);
                if (MKMapRectIsNull(zoomRect)) {
                    zoomRect = pointRect;
                } else {
                    zoomRect = MKMapRectUnion(zoomRect, pointRect);
                }
            }
        }
        
        UIEdgeInsets edgePadding = UIEdgeInsetsMake(100, 100, 100, 100);
        [self.mapView setVisibleMapRect:zoomRect edgePadding:edgePadding animated:YES];
    }
}

- (BOOL)searchDisplayController:(SearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self.searchStolpersteineOperation cancel];
    
    StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
    searchData.keyword = searchString;
    self.searchStolpersteineOperation = [AppDelegate.networkService retrieveStolpersteineWithSearchData:searchData range:NSMakeRange(0, 0) completionHandler:^(NSArray *stolpersteine, NSError *error) {
        NSLog(@"shouldReloadTableForSearchString %d (%@)", stolpersteine.count, error);

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
    cell.detailTextLabel.text = [Localization newAddressShortFromStolperstein:stolperstein];

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
     
    // Check if stolperstein already exists as annotation; otherwise, it gets
    // added when selecting it
    Stolperstein *stolperstein = [self.searchedStolpersteine objectAtIndex:indexPath.row];
    StolpersteinAnnotation *stolpersteinAnnotation = [[StolpersteinAnnotation alloc] initWithStolperstein:stolperstein];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"class == %@ AND stolperstein.id == %@", StolpersteinAnnotation.class, stolperstein.id];
    NSArray *annotations = [self.mapView.annotations filteredArrayUsingPredicate:predicate];
    if (annotations.count != 0) {
        stolperstein = annotations.lastObject;
    }
    
    // Deselect all annotations
    for (id<MKAnnotation> selectedAnnotation in self.mapView.selectedAnnotations) {
        [self.mapView deselectAnnotation:selectedAnnotation animated:TRUE];
    }
    
    // Center on stolperstein and select it
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(stolpersteinAnnotation.coordinate, 1200, 1200);
    BOOL isRegionUpToDate = fequal(region.center.latitude, self.mapView.region.center.latitude) && fequal(region.center.longitude, self.mapView.region.center.longitude);
    
    if (isRegionUpToDate) {
        // Select immediately since annotation is already visible
        [self.mapView setRegion:region animated:YES];
        [self.mapView selectAnnotation:stolpersteinAnnotation animated:YES];
    } else {
        // Actual selection happens in mapView:regionDidChangeAnimated:
        [self.mapView setRegion:region animated:YES];
        self.stolpersteinAnnotationToSelect = stolpersteinAnnotation;
    }
    
    [self.searchDisplayController setActive:FALSE animated:TRUE];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id<MKAnnotation> selectedAnnotation = self.mapView.selectedAnnotations.lastObject;
    if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteinDetailViewController"]) {
        StolpersteinAnnotation *stolpersteinAnnotation = (StolpersteinAnnotation *)selectedAnnotation;
        StolpersteinDetailViewController *detailViewController = (StolpersteinDetailViewController *)segue.destinationViewController;
        detailViewController.stolperstein = stolpersteinAnnotation.stolperstein;
    } else if ([segue.identifier isEqualToString:@"mapViewControllerToStolpersteineListViewController"]) {
//        StolpersteineListViewController *listViewController = (StolpersteineListViewController *)segue.destinationViewController;
//        StolpersteinGroup *stolpersteinGroup = (StolpersteinGroup *)selectedAnnotation;
//        listViewController.stolpersteine = stolpersteinGroup.stolpersteine;
//        listViewController.title = stolpersteinGroup.title;
    }
}

@end
