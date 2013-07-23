//
//  WebViewController.m
//  Stolpersteine
//
//  Created by Claus on 04.07.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "WebViewController.h"

#import "TUSafariActivity.h"
#import "NJKWebViewProgress.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface WebViewController() <NJKWebViewProgressDelegate>

@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;

@end

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Receive progress updates for content loading
    self.webViewProgress = [[NJKWebViewProgress alloc] init];
    self.webView.delegate = self.webViewProgress;
    self.webViewProgress.progressDelegate = self;
    self.webViewProgress.webViewProxyDelegate = self;

    // Display progress in navigation bar
    UIProgressView *progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    progressView.progressTintColor = UIColor.grayColor;
    self.progressView = progressView;
    self.navigationItem.titleView = self.progressView;

    // Load web site
    self.webView.scalesPageToFit = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.networkActivityIndicatorVisible = NO;
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

- (void)webViewProgress:(NJKWebViewProgress *)webViewProgress updateProgress:(float)progress
{
    if (progress == 0.0) {
        self.networkActivityIndicatorVisible = YES;
        self.navigationItem.titleView = self.progressView;
    } else if (progress == 1.0) {
        self.networkActivityIndicatorVisible = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.navigationItem.titleView = nil;
            self.progressView.alpha = 1.0;
        }];
    }
    
    self.progressView.progress = progress;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    self.networkActivityIndicatorVisible = NO;
    self.navigationItem.titleView = nil;
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSArray *itemsToShare = self.itemsToShare.count > 0 ? self.itemsToShare : @[self.url];
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:@[activity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
