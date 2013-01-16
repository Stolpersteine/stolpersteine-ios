//
//  ViewController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *centerMapBarButtonItem;

- (IBAction)centerMap:(UIButton *)sender;

@end
