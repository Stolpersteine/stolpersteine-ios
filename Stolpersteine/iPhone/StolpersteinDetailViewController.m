//
//  DetailViewController.m
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
#import "ImageGalleryViewController.h"
#import "RoundedRectButton.h"
#import "StolpersteinDescriptionViewController.h"

@interface StolpersteinDetailViewController()

@property (nonatomic, strong) ImageGalleryViewController *imageGalleryViewController;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"StolpersteinDetailViewController.title", nil);
    
//    if (self.stolperstein == nil) {
//        self.stolperstein = [[Stolperstein alloc] init];
//    }
//    NSString *urlString0 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Stolperstein_Robert_Remak%2C_Berlin_01.jpg/640px-Stolperstein_Robert_Remak%2C_Berlin_01.jpg";
//    NSString *urlString1 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/a7/Wismar_St._Marien_2008-06-10.jpg/450px-Wismar_St._Marien_2008-06-10.jpg";
//    NSString *urlString2 = @"http://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Stolperstein_Elberfelder_Str_20_%28Moab%29_Margarete_Alexander.jpg/300px-Stolperstein_Elberfelder_Str_20_%28Moab%29_Margarete_Alexander.jpg";
//    self.stolperstein.imageURLStrings = @[urlString0, urlString1, urlString2];
    
//    self.stolperstein.personBiographyURLString = @"http://www.bochum.de/C12571A3001D56CE/vwContentByKey/W287J9EG297BOLDDE/$FILE/016_018_Simons_Ellen_Sophie_und_Hermann.pdf";
//    self.stolperstein.personBiographyURLString = @"http://asd";
    
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
        self.allInThisStreetButton.chevronEnabled = YES;
    }

    // Biography button
    if (self.stolperstein.personBiographyURLString) {
        NSString *key = (self.stolperstein.type == StolpersteinTypeStolperschwelle) ? @"StolpersteinDetailViewController.description" : @"StolpersteinDetailViewController.biography";
        NSString *biographyButtonTitle = NSLocalizedString(key, nil);
        [self.biographyButton setTitle:biographyButtonTitle forState:UIControlStateNormal];
        self.biographyButton.chevronEnabled = YES;
    } else {
        [self.biographyButton removeFromSuperview];
    }
    
    // Maps button
    NSString *mapsButtonTitle = NSLocalizedString(@"StolpersteinDetailViewController.maps", nil);
    [self.mapsAppButton setTitle:mapsButtonTitle forState:UIControlStateNormal];

    // Source
    NSString *linkText = self.stolperstein.sourceName;
    NSString *localizedSourceText = NSLocalizedString(@"StolpersteinDetailViewController.source", nil);
    NSString *sourceText = [NSString stringWithFormat:localizedSourceText, linkText];
    NSRange linkRange = NSMakeRange(sourceText.length - linkText.length, linkText.length);
    NSMutableAttributedString *sourceAttributedString = [[NSMutableAttributedString alloc] initWithString:sourceText];
    [sourceAttributedString setAttributes:@{ NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle) } range:linkRange];
    self.sourceLabel.attributedText = sourceAttributedString;
    self.sourceLabel.font = [UIFont systemFontOfSize:UIFont.labelFontSize - 5];

    UIGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showSourceURL)];
    [self.sourceLabel addGestureRecognizer:tapGestureRecognizer];
    self.sourceLabel.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self.scrollView flashScrollIndicators];
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

- (void)showSourceURL
{
    NSURL *sourceURL = [NSURL URLWithString:self.stolperstein.sourceURLString];
    [UIApplication.sharedApplication openURL:sourceURL];
}

- (NSArray *)itemsToShare
{
    NSString *textItem = [Localization newDescriptionFromStolperstein:self.stolperstein];
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:textItem];
    if (self.stolperstein.personBiographyURLString) {
        [itemsToShare addObject:[NSURL URLWithString:self.stolperstein.personBiographyURLString]];
    }
    return itemsToShare;
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:self.itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
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
        searchData.street = [Localization newStreetNameFromStolperstein:self.stolperstein];
        StolpersteinListViewController *listViewController = (StolpersteinListViewController *)segue.destinationViewController;
        listViewController.searchData = searchData;
        listViewController.title = searchData.street;
    } else if ([segue.identifier isEqualToString:@"stolpersteinDetailViewControllerToWebViewController"]) {
        NSURL *url = [[NSURL alloc] initWithString:self.stolperstein.personBiographyURLString];
        StolpersteinDescriptionViewController *webViewController = (StolpersteinDescriptionViewController *)segue.destinationViewController;
        webViewController.url = url;
        NSString *localizedTitle = (self.stolperstein.type == StolpersteinTypeStolperschwelle) ? @"StolpersteinDetailViewController.webViewTitleDescription" : @"StolpersteinDetailViewController.webViewTitleBiography";
        webViewController.title = NSLocalizedString(localizedTitle, nil);
        NSString *name = [Localization newNameFromStolperstein:self.stolperstein];
        UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:name style:UIBarButtonItemStyleBordered target:nil action:nil];
        self.navigationItem.backBarButtonItem = backBarButtonItem;
    }
}

@end
