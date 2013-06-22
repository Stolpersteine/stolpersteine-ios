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
#import "Localization.h"
#import "LinkedTextLabel.h"
#import "ImageGalleryViewController.h"

@interface StolpersteinDetailViewController()

@property (nonatomic, strong) ImageGalleryViewController *imageGalleryViewController;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"StolpersteinDetailViewController.title", nil);
    
    if (self.stolperstein == nil) {
        self.stolperstein = [[Stolperstein alloc] init];
    }
    NSString *urlString0 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Stolperstein_Robert_Remak%2C_Berlin_01.jpg/640px-Stolperstein_Robert_Remak%2C_Berlin_01.jpg";
    NSString *urlString1 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Wismar_St._Marien_2008-06-10.jpg/450px-Wismar_St._Marien_2008-06-10.jpg";
    NSString *urlString2 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Stolperstein_Elberfelder_Str_20_%28Moab%29_Margarete_Alexander.jpg/300px-Stolperstein_Elberfelder_Str_20_%28Moab%29_Margarete_Alexander.jpg";
    self.stolperstein.imageURLStrings = @[urlString0, urlString1, urlString2];
    
    // Name and address
    Stolperstein *stolperstein = self.stolperstein;
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    self.nameLabel.text = name;
    self.nameLabel.font = [UIFont boldSystemFontOfSize:UIFont.labelFontSize + 3];
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    self.addressLabel.text = address;

    // Image gallery
    if (stolperstein.imageURLStrings.count == 0) {
        [self.imageGalleryView removeFromSuperview];
    } else {
        self.imageGalleryViewController.imageURLStrings = stolperstein.imageURLStrings;
    }
    
    // Street button
    if (self.isAllInThisStreetButtonHidden) {
        [self.allInThisStreetButton removeFromSuperview];
    } else {
        NSString *streetButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.street", nil);
        [self.allInThisStreetButton setTitle:streetButtonTitle forState:UIControlStateNormal];
    }

    // Biography button
    if (self.stolperstein.personBiographyURLString) {
        NSString *biographyButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.biography", nil);
        [self.biographyButton setTitle:biographyButtonTitle forState:UIControlStateNormal];
    } else {
        [self.biographyButton removeFromSuperview];
    }
    
    // Maps button
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    [self.mapsAppButton setTitle:mapsButtonTitle forState:UIControlStateNormal];

    // Source
    NSString *linkText = @"Koordinierungsstelle Stolpersteine Berlin";
    NSURL *linkURL = [NSURL URLWithString:@"http://www.stolpersteine-berlin.de/"];

    NSString *localizedSourceText = NSLocalizedString(@"StolpersteinDetailViewController.source", nil);
    NSString *sourceText = [NSString stringWithFormat:localizedSourceText, linkText];
    NSRange linkRange = NSMakeRange(sourceText.length - linkText.length, linkText.length);
    NSMutableAttributedString *sourceAttributedString = [[NSMutableAttributedString alloc] initWithString:sourceText];
    [sourceAttributedString setAttributes:@{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) } range:linkRange];
    self.sourceLinkedTextLabel.attributedText = sourceAttributedString;
    [self.sourceLinkedTextLabel setLink:linkURL range:linkRange];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

- (UIButton *)newRoundedRectButtonWithTitle:(NSString *)title action:(SEL)action chevronEnabled:(BOOL)chevronEnabled
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    UIImage *backgroundImage = [[UIImage imageNamed:@"rounded-rect-frame.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    
    if (chevronEnabled) {
        UIImage *chevron = [UIImage imageNamed:@"icon-chevron.png"];
        [button setImage:chevron forState:UIControlStateNormal];
        [button sizeToFit];
        button.titleEdgeInsets = UIEdgeInsetsMake(0, -chevron.size.width, 0, 0);
    }
    
    return button;
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSString *textItem = [Localization newDescriptionFromStolperstein:self.stolperstein];
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:textItem];
    if (self.stolperstein.personBiographyURLString) {
        [itemsToShare addObject:[NSURL URLWithString:self.stolperstein.personBiographyURLString]];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)showAllInThisStreet:(UIButton *)sender
{
    [self performSegueWithIdentifier:@"stolpersteinDetailViewControllerToStolpersteinListViewController" sender:self];
}

- (void)showBiography:(UIButton *)sender
{
    NSURL *url = [[NSURL alloc] initWithString:self.stolperstein.personBiographyURLString];
    [UIApplication.sharedApplication openURL:url];
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
    if ([segue.identifier isEqualToString:@"imageGalleryViewController"]) {
        ImageGalleryViewController *imageGalleryViewController = (ImageGalleryViewController *)segue.destinationViewController;
        imageGalleryViewController.spacing = 20;
        imageGalleryViewController.clipsToBounds = NO;
        self.imageGalleryViewController = imageGalleryViewController;
    } else if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToStolpersteinListViewController"]) {
        StolpersteinSearchData *searchData = [[StolpersteinSearchData alloc] init];
        searchData.locationStreet = [Localization newStreetNameFromStolperstein:self.stolperstein];
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.locationStreet;
    }
}

@end
