//
//  DetailViewController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinDetailViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <AddressBook/AddressBook.h>
#import <MapKit/MapKit.h>

#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteineListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CopyableImageView.h"
#import "Localization.h"

#define PADDING 20

@interface StolpersteinDetailViewController()

@property (strong, nonatomic) CopyableImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *biographyButton;
@property (strong, nonatomic) UIButton *streetButton;
@property (strong, nonatomic) UIButton *mapsButton;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = [Localization newNameFromStolperstein:self.stolperstein];

    // Image
    self.imageView = [[CopyableImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];

    UIEdgeInsets frameEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    UIImage *frameImage = [[UIImage imageNamed:@"image-frame.png"] resizableImageWithCapInsets:frameEdgeInsets];
    UIImageView *frameImageView = [[UIImageView alloc] initWithImage:frameImage];
    frameImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.imageView addSubview:frameImageView];
    
    self.imageActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.imageActivityIndicator.hidesWhenStopped = TRUE;
    [self.imageView addSubview:self.imageActivityIndicator];
    
    NSString *address = [Localization newAddressLongFromStolperstein:self.stolperstein];
    NSAttributedString *addressText = [[NSAttributedString alloc] initWithString:address];
    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.attributedText = addressText;
    self.addressLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.addressLabel];
    
    // Biography button
    self.biographyButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *biographyButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.biography", nil);
    self.biographyButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.biographyButton setTitle:biographyButtonTitle forState:UIControlStateNormal];
    [self.biographyButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.biographyButton addTarget:self action:@selector(showBiography:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.biographyButton];

    // Street button
    self.streetButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *streetButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.street", nil);
    self.streetButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.streetButton setTitle:streetButtonTitle forState:UIControlStateNormal];
    [self.streetButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.streetButton addTarget:self action:@selector(showAllInThisStreet:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.streetButton];

    // Maps button
    self.mapsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    self.mapsButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.mapsButton setTitle:mapsButtonTitle forState:UIControlStateNormal];
    [self.mapsButton setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [self.mapsButton addTarget:self action:@selector(showInMapsApp:) forControlEvents:UIControlEventTouchUpInside];
    [self.scrollView addSubview:self.mapsButton];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.stolperstein.imageURLString && !self.imageView.image) {
        [self loadImageWithURLString:self.stolperstein.imageURLString];
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView cancelImageRequestOperation];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setImageActivityIndicator:nil];
    [self setScrollView:nil];

    [super viewDidUnload];
}

- (void)loadImageWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    [self.imageActivityIndicator startAnimating];
    
    __weak StolpersteinDetailViewController *weakSelf = self;
    [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        weakSelf.imageView.image = image;
        [weakSelf.imageActivityIndicator stopAnimating];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        [weakSelf.imageActivityIndicator stopAnimating];
    }];
}

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat height = PADDING;
    
    // Image
    if (self.stolperstein.imageURLString) {
        self.imageView.hidden = NO;
        self.imageView.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
        CGRect imageActivityIndicatorFrame = self.imageActivityIndicator.frame;
        imageActivityIndicatorFrame.origin.x = (self.imageView.frame.size.width - self.imageActivityIndicator.frame.size.width) * 0.5;
        imageActivityIndicatorFrame.origin.y = (self.imageView.frame.size.height - self.imageActivityIndicator.frame.size.height) * 0.5;
        self.imageActivityIndicator.frame = imageActivityIndicatorFrame;
        height += self.imageView.frame.size.height + PADDING * 0.5;
    } else {
        self.imageView.hidden = YES;
    }
    
    // Address
    CGRect addressFrame;
    addressFrame.origin.x = PADDING;
    addressFrame.origin.y = height;
    addressFrame.size = [self.addressLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.addressLabel.frame = addressFrame;
    height += addressFrame.size.height + PADDING * 0.5;

    // Biography button
    if (self.stolperstein.personBiographyURLString) {
        self.biographyButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.biographyButton.frame.size.height + PADDING * 0.5;
    }

    // Street button
    if (!self.isAllInThisStreetButtonHidden) {
        self.streetButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.streetButton.frame.size.height + PADDING * 0.5;
    }
    
    // Maps button
    self.mapsButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
    height += self.mapsButton.frame.size.height + PADDING * 0.5;
    
    // Scroll view
    height += PADDING * 0.5;
    self.scrollView.contentSize = CGSizeMake(screenWidth, height);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:self.title];
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)showBiography:(UIButton *)sender
{
    NSURL *url = [[NSURL alloc] initWithString:self.stolperstein.personBiographyURLString];
    [UIApplication.sharedApplication openURL:url];
}

- (void)showAllInThisStreet:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"stolpersteinDetailViewControllerToStolpersteineListViewController" sender:self];
}

- (void)showInMapsApp:(UIButton *)sender
{
    // Create an MKMapItem to pass to the Maps app
    CLLocationCoordinate2D coordinate = self.stolperstein.locationCoordinates.coordinate;
    NSMutableDictionary *addressDictionary = [NSMutableDictionary dictionaryWithCapacity:3];
    if (self.stolperstein.locationStreet) {
        [addressDictionary setObject:self.stolperstein.locationStreet forKey:(NSString *)kABPersonAddressStreetKey];
    }
    if (self.stolperstein.locationCity) {
        [addressDictionary setObject:self.stolperstein.locationCity forKey:(NSString *)kABPersonAddressCityKey];
    }
    if (self.stolperstein.locationZipCode) {
        [addressDictionary setObject:self.stolperstein.locationZipCode forKey:(NSString *)kABPersonAddressZIPKey];
    }
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [Localization newNameFromStolperstein:self.stolperstein];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToStolpersteineListViewController"]) {
        StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
        searchData.locationStreet = self.stolperstein.locationStreetName;
        StolpersteineListViewController *listViewController = (StolpersteineListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.locationStreet;
    }
}

@end
