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

#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "Stolperstein.h"
#import "StolpersteinSearchData.h"
#import "StolpersteinListViewController.h"
#import "UIImageView+AFNetworking.h"
#import "CopyableImageView.h"
#import "Localization.h"

#define PADDING 20

@interface StolpersteinDetailViewController()

@property (strong, nonatomic) CopyableImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic) UILabel *nameLabel;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *biographyButton;
@property (strong, nonatomic) UIButton *streetButton;
@property (strong, nonatomic) UIButton *mapsButton;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"StolpersteinDetailViewController.title", nil);
    
    // Name
    self.nameLabel = [[UILabel alloc] init];
    NSString *name = [Localization newNameFromStolperstein:self.stolperstein];
    self.nameLabel.text = name;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:UIFont.labelFontSize + 3];
    self.nameLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.nameLabel];
    
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
    
    // Address
    self.addressLabel = [[UILabel alloc] init];
    NSString *address = [Localization newLongAddressFromStolperstein:self.stolperstein];
    self.addressLabel.text = address;
    self.addressLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.addressLabel];
    
    // Street button
    NSString *streetButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.street", nil);
    self.streetButton = [self newRoundedRectButtonWithTitle:streetButtonTitle action:@selector(showAllInThisStreet:) chevronEnabled:TRUE];
    [self.scrollView addSubview:self.streetButton];

    // Biography button
    NSString *biographyButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.biography", nil);
    self.biographyButton = [self newRoundedRectButtonWithTitle:biographyButtonTitle action:@selector(showBiography:) chevronEnabled:FALSE];
    [self.scrollView addSubview:self.biographyButton];

    // Maps button
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    self.mapsButton = [self newRoundedRectButtonWithTitle:mapsButtonTitle action:@selector(showInMapsApp:) chevronEnabled:FALSE];
    [self.scrollView addSubview:self.mapsButton];
}

- (UIButton *)newRoundedRectButtonWithTitle:(NSString *)title action:(SEL)action chevronEnabled:(BOOL)chevronEnabled
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    
    if (chevronEnabled) {
        UIImage *chevron = [UIImage imageNamed:@"chevron.png"];
        [button setImage:chevron forState:UIControlStateNormal];
        [button sizeToFit];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -chevron.size.width, 0, 0);
        button.imageEdgeInsets = UIEdgeInsetsMake(0, button.titleLabel.frame.size.width + button.frame.size.width - 10, 0, 0);
    }
    
    return button;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.stolperstein.imageURLString && !self.imageView.image) {
        [self loadImageWithURLString:self.stolperstein.imageURLString];
    }
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewController:self];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView cancelImageRequestOperation];
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
    
    // Name
    CGRect nameFrame;
    nameFrame.origin.x = PADDING;
    nameFrame.origin.y = height;
    nameFrame.size = [self.nameLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.nameLabel.frame = nameFrame;
    height += nameFrame.size.height + PADDING * 0.5;

    // Image
    self.imageView.hidden = !self.stolperstein.imageURLString;
    if (self.stolperstein.imageURLString) {
        self.imageView.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
        CGRect imageActivityIndicatorFrame = self.imageActivityIndicator.frame;
        imageActivityIndicatorFrame.origin.x = (self.imageView.frame.size.width - self.imageActivityIndicator.frame.size.width) * 0.5;
        imageActivityIndicatorFrame.origin.y = (self.imageView.frame.size.height - self.imageActivityIndicator.frame.size.height) * 0.5;
        self.imageActivityIndicator.frame = imageActivityIndicatorFrame;
        height += self.imageView.frame.size.height + PADDING * 0.5;
    }
    
    // Address
    CGRect addressFrame;
    addressFrame.origin.x = PADDING;
    addressFrame.origin.y = height;
    addressFrame.size = [self.addressLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.addressLabel.frame = addressFrame;
    height += addressFrame.size.height + PADDING * 0.5;

    // Street button
    self.streetButton.hidden = self.isAllInThisStreetButtonHidden;
    if (!self.isAllInThisStreetButtonHidden) {
        self.streetButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.streetButton.frame.size.height + PADDING * 0.5;
    }
    
    // Biography button
    self.biographyButton.hidden = !self.stolperstein.personBiographyURLString;
    if (self.stolperstein.personBiographyURLString) {
        self.biographyButton.frame = CGRectMake(PADDING, height, screenWidth - 2 * PADDING, 44);
        height += self.biographyButton.frame.size.height + PADDING * 0.5;
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
    NSString *textItem = [Localization newDescriptionFromStolperstein:self.stolperstein];
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:textItem];
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    if (self.stolperstein.personBiographyURLString) {
        [itemsToShare addObject:[NSURL URLWithString:self.stolperstein.personBiographyURLString]];
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
    CLLocationCoordinate2D coordinate = self.stolperstein.locationCoordinate;
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    mapItem.name = [Localization newNameFromStolperstein:self.stolperstein];
    [mapItem openInMapsWithLaunchOptions:nil];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToStolpersteineListViewController"]) {
        StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
        searchData.locationStreet = [Localization newStreetNameFromStolperstein:self.stolperstein];
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.locationStreet;
    }
}

@end
