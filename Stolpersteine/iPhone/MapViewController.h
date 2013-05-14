//
//  ViewController.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 07.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@class SearchBar;

@interface MapViewController : UIViewController

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet SearchBar *searchBar;
@property (weak, nonatomic) IBOutlet UIButton *imprintButton;
@property (strong, nonatomic) UIButton *locationButton;

- (IBAction)centerMap:(UIButton *)sender;
- (IBAction)showImprint:(UIButton *)sender;

@end
