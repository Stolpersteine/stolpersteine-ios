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

#import "TUSafariActivity.h"
#import "NJKWebViewProgress.h"
#import "AFNetworkActivityIndicatorManager.h"
#import "AppDelegate.h"
#import "DiagnosticsService.h"

@interface StolpersteinDescriptionViewController() <NJKWebViewProgressDelegate>

@property (nonatomic, strong) NJKWebViewProgress *webViewProgress;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, assign, getter = isProgressViewVisible) BOOL progressViewVisible;
@property (nonatomic, assign, getter = isNetworkActivityIndicatorVisible) BOOL networkActivityIndicatorVisible;
@property (nonatomic, strong) NSString *webViewTitle;

@end

@implementation StolpersteinDescriptionViewController

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
    self.progressViewVisible = YES;

    // Load web site
    self.webView.scalesPageToFit = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
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
        self.navigationItem.titleView = self.progressView;
    } else {
        self.navigationItem.titleView = nil;
    }
}

- (BOOL)isProgressViewVisible
{
    return (self.navigationItem.titleView == self.progressView);
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
        self.progressViewVisible = YES;
    } else if (progress == 1.0) {
        self.networkActivityIndicatorVisible = NO;
        [UIView animateWithDuration:0.3 animations:^{
            self.progressView.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.progressViewVisible = NO;
            self.progressView.alpha = 1.0;
        }];
    }
    
    self.progressView.progress = progress;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    self.webViewTitle = nil;
    [self updateActivityButton];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    self.webViewTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    [self updateActivityButton];
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
    NSArray *itemsToShare = @[self.webViewTitle, self.webView.request.URL];
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:@[activity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
