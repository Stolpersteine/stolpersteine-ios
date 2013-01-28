//
//  ViewController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchBarView;

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *centerMapBarButtonItem;
@property (weak, nonatomic) IBOutlet SearchBarView *searchBarView;

- (IBAction)centerMap:(UIButton *)sender;
- (IBAction)showSearchDisplayController:(UITextField *)sender;

@end
