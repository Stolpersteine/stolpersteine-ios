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
#import <MapKit/MapKit.h>

@interface MapViewController () <MKMapViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, assign, getter = isUserLocationMode) BOOL userLocationMode;

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Make UISearchBar transparent
    self.searchBar.backgroundImage = [UIImage new];
    self.searchBar.translucent = YES;
    
    // Set map location to Berlin
    CLLocationCoordinate2D location = CLLocationCoordinate2DMake(52.5233, 13.4127);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(location, 12000, 12000);
    self.mapView.region = region;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
}

- (void)viewDidUnload
{
    self.locationManager.delegate = nil;

    [self setMapView:nil];
    [self setSearchBar:nil];
    [self setCenterMapBarButtonItem:nil];
    
    [super viewDidUnload];
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    [AppDelegate.networkService retrieveStolpersteineWithSearchData:nil page:0 pageSize:0 completionHandler:^(NSArray *stolpersteine, NSUInteger totalNumberOfItems, NSError *error) {
        NSLog(@"retrieveStolpersteineWithSearchData %d", stolpersteine.count);

        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF != %@", mapView.userLocation];
        NSArray *annotations = [mapView.annotations filteredArrayUsingPredicate:predicate];
        [mapView removeAnnotations:annotations];
        [mapView addAnnotations:stolpersteine];
    }];
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    MKAnnotationView *annotationView;
    
    if ([annotation isKindOfClass:Stolperstein.class]) {
        static NSString *stolpersteinIdentifier = @"stolpersteinIdentifier";
        
        annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:stolpersteinIdentifier];
        if (annotationView) {
            annotationView.annotation = annotation;
        } else {
            MKPinAnnotationView *pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:stolpersteinIdentifier];
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [rightButton addTarget:self action:@selector(showDetails:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        self.mapView.showsUserLocation = TRUE;
    } else {
        self.userLocation = nil;
        self.mapView.showsUserLocation = FALSE;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setRightBarButtonItem:nil animated:TRUE];
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self.navigationItem setRightBarButtonItem:self.centerMapBarButtonItem animated:TRUE];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"search");
}

- (void)showDetails:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"mapViewControllerToDetailViewController" sender:self];
}

- (IBAction)centerMap:(UIButton *)sender
{
    if (!self.isUserLocationMode && self.userLocation.location) {
        self.userLocationMode = TRUE;
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, 12000, 12000);
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

@end
