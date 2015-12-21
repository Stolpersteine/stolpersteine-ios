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
#import "MapSearchDisplayController.h"
#import "MapClusterAnnotationView.h"
#import "Localization.h"

#import "StolpersteineSynchronizationController.h"
#import "StolpersteinSynchronizationControllerDelegate.h"
#import "StolpersteinCardsViewController.h"
#import "StolpersteineNetworkService.h"

#import "CCHMapClusterController.h"
#import "CCHMapClusterControllerDelegate.h"
#import "CCHMapClusterAnnotation.h"

static const double ZOOM_DISTANCE_USER = 1200;
static const double ZOOM_DISTANCE_STOLPERSTEIN = ZOOM_DISTANCE_USER * 0.25;

@interface MapViewController () <MKMapViewDelegate, CLLocationManagerDelegate, CCHMapClusterControllerDelegate, StolpersteineSynchronizationControllerDelegate>

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *infoButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *locationBarButtonItem;
@property (weak, nonatomic) IBOutlet MapSearchDisplayController *mapSearchDisplayController;

@property (nonatomic) CLLocationManager *locationManager;
@property (nonatomic) BOOL displayRegionIcon;
@property (nonatomic) StolpersteineSynchronizationController *stolpersteinSyncController;
@property (nonatomic) CCHMapClusterController *mapClusterController;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"MapViewController.title", nil);
    self.mapView.showsBuildings = YES;
    self.infoButton.accessibilityLabel = NSLocalizedString(@"MapViewController.info", nil);
    
    // Clustering
    self.mapClusterController = [[CCHMapClusterController alloc] initWithMapView:self.mapView];
    self.mapClusterController.delegate = self;
    
    // Navigation bar
    self.mapSearchDisplayController.networkService = [AppDelegate networkService];
    self.mapSearchDisplayController.mapClusterController = self.mapClusterController;
    self.mapSearchDisplayController.zoomDistance = ZOOM_DISTANCE_STOLPERSTEIN;
    self.mapSearchDisplayController.delegate = self.mapSearchDisplayController;
    self.mapSearchDisplayController.searchResultsDataSource = self.mapSearchDisplayController;
    self.mapSearchDisplayController.searchResultsDelegate = self.mapSearchDisplayController;
    
    [self.mapSearchDisplayController.searchBar removeFromSuperview];
    self.mapSearchDisplayController.displaysSearchBarInNavigationBar = YES;
    self.mapSearchDisplayController.navigationItem.rightBarButtonItem = self.locationBarButtonItem;
    self.mapSearchDisplayController.searchBar.placeholder = NSLocalizedString(@"MapViewController.searchBarPlaceholder", nil);
    [self updateSearchBarForInterfaceOrientation:self.interfaceOrientation];
    
    // User location
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        [self.locationManager requestWhenInUseAuthorization];
    }
    
    // Start loading data
    self.stolpersteinSyncController = [[StolpersteineSynchronizationController alloc] initWithNetworkService:AppDelegate.networkService];
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
    NSString *imageName = UIInterfaceOrientationIsLandscape(interfaceOrientation) ? @"SearchBarBackgroundLandscape" : @"SearchBarBackground";
    UIImage *backgroundImage = [UIImage imageNamed:imageName];
    [self.searchDisplayController.searchBar setSearchFieldBackgroundImage:backgroundImage forState:UIControlStateNormal];
}

- (void)updateLocationBarButtonItem
{
    // Force region mode if locations aren't available
    BOOL isAuthorized = [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse;
    if (![CLLocationManager locationServicesEnabled] || !isAuthorized) {
        self.displayRegionIcon = YES;
    }

    UIImage *image;
    NSString *accessibilityLabel;
    if (self.displayRegionIcon) {
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
    self.displayRegionIcon = !self.displayRegionIcon;
    
    NSString *diagnosticsLabel;
    if (self.displayRegionIcon) {
        if (self.mapView.userLocation.location) {
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.mapView.userLocation.coordinate, ZOOM_DISTANCE_USER, ZOOM_DISTANCE_USER);
            [self.mapView setRegion:region animated:YES];
        }
        diagnosticsLabel = @"userLocation";
    } else {
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

- (void)stolpersteinSynchronizationController:(StolpersteineSynchronizationController *)stolpersteinSynchronizationController didAddStolpersteine:(NSArray *)stolpersteine
{
    [self.mapClusterController addAnnotations:stolpersteine withCompletionHandler:NULL];
}

#pragma mark - Map view

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:CCHMapClusterAnnotation.class]) {
        static NSString *identifier = @"stolpersteinCluster";
        
        MapClusterAnnotationView *mapClusterAnnotationView = (MapClusterAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
        if (mapClusterAnnotationView) {
            mapClusterAnnotationView.annotation = annotation;
        } else {
            mapClusterAnnotationView = [[MapClusterAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
            mapClusterAnnotationView.canShowCallout = YES;

            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            if (NSFoundationVersionNumber > NSFoundationVersionNumber_iOS_7_1) {
                // Workaround for misaligned button, see http://stackoverflow.com/questions/25484608/ios-8-mkannotationview-rightcalloutaccessoryview-misaligned
                CGRect frame = rightButton.frame;
                frame.size.height = 55;
                frame.size.width = 55;
                rightButton.frame = frame;
            }
            mapClusterAnnotationView.rightCalloutAccessoryView = rightButton;
        }
        
        CCHMapClusterAnnotation *mapClusterAnnotation = (CCHMapClusterAnnotation *)annotation;
        mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
        mapClusterAnnotationView.oneLocation = mapClusterAnnotation.isUniqueLocation;
        
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
    if (status == kCLAuthorizationStatusAuthorized || status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        self.mapView.showsUserLocation = YES;
        [self.locationManager startUpdatingLocation];
    } else {
        self.mapView.showsUserLocation = NO;
        [self.locationManager stopUpdatingLocation];
    }
    [self updateLocationBarButtonItem];
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
    MapClusterAnnotationView *mapClusterAnnotationView = (MapClusterAnnotationView *)[self.mapClusterController.mapView viewForAnnotation:mapClusterAnnotation];
    mapClusterAnnotationView.count = mapClusterAnnotation.annotations.count;
    mapClusterAnnotationView.oneLocation = mapClusterAnnotation.isUniqueLocation;
}

@end
