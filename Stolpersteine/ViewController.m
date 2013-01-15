//
//  ViewController.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () <MKMapViewDelegate, UITableViewDataSource, UISearchBarDelegate, CLLocationManagerDelegate>

@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation ViewController

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
    [self setNavigationBar:nil];
    [self setCenterLocationBarButtonItem:nil];
    
    [super viewDidUnload];
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

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    [self.navigationBar.topItem setRightBarButtonItem:nil animated:TRUE];
    
    return TRUE;
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    [self.navigationBar.topItem setRightBarButtonItem:self.centerLocationBarButtonItem animated:TRUE];
    
    return TRUE;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSLog(@"%@", searchText);
}

- (IBAction)centerToUserLocation:(UIButton *)sender
{
    if (self.userLocation.location) {
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(self.userLocation.location.coordinate, 12000, 12000);
        [self.mapView setRegion:region animated:YES];
    }
}

@end
