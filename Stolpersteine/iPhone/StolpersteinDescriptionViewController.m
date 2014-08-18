//
//  WebViewController.m
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

#import "StolpersteinDescriptionViewController.h"

#import "Stolperstein.h"
#import "TUSafariActivity.h"
#import "CCHMapsActivity.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "DiagnosticsService.h"
#import "Localization.h"

#import <AddressBook/AddressBook.h>

@interface StolpersteinDescriptionViewController()

@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *activityBarButtonItem;

@property (nonatomic) UIBarButtonItem *activityIndicatorBarButtonItem;
@property (nonatomic) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;
@property (nonatomic, copy) NSString *webViewTitle;

@end

@implementation StolpersteinDescriptionViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Display progress in navigation bar    
    UIActivityIndicatorView * activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.activityIndicatorView = activityIndicatorView;
    self.activityIndicatorBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:activityIndicatorView];
    [self.activityIndicatorBarButtonItem setStyle:UIBarButtonItemStyleBordered];
    self.progressViewVisible = YES;

    // Load web site
    self.webView.delegate = self;
    self.webView.scalesPageToFit = YES;
    NSURL *url = [Localization newPersonBiographyURLFromStolperstein:self.stolperstein];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateActivityButton];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.networkActivityIndicatorVisible = NO;
}

- (void)setProgressViewVisible:(BOOL)progressViewVisible
{
    if (progressViewVisible) {
        [self.activityIndicatorView startAnimating];
        self.navigationItem.rightBarButtonItem = self.activityIndicatorBarButtonItem;
    } else {
        [self.activityIndicatorView stopAnimating];
        self.navigationItem.rightBarButtonItem = self.activityBarButtonItem;
    }
}

- (void)setNetworkActivityIndicatorVisible:(BOOL)networkActivityIndicatorVisible
{
    if (networkActivityIndicatorVisible != _networkActivityIndicatorVisible) {
        if (networkActivityIndicatorVisible) {
            [AFNetworkActivityIndicatorManager.sharedManager incrementActivityCount];
        } else {
            [AFNetworkActivityIndicatorManager.sharedManager decrementActivityCount];
        }
        _networkActivityIndicatorVisible = networkActivityIndicatorVisible;
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.webViewTitle = nil;
    [self updateActivityButton];
    self.progressViewVisible = YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webViewTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateActivityButton];
    self.progressViewVisible = NO;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.networkActivityIndicatorVisible = NO;
    self.progressViewVisible = NO;
}

- (void)updateActivityButton
{
    self.activityBarButtonItem.enabled = (self.webViewTitle && self.webView.request.URL);
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
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

    // Configure activity items
    NSArray *itemsToShare = @[self.webViewTitle, self.webView.request.URL, mapItem];
    TUSafariActivity *safariActivity = [[TUSafariActivity alloc] init];
    CCHMapsActivity *mapsActivity = [[CCHMapsActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:@[safariActivity, mapsActivity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
