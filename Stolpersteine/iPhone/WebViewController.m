//
//  WebViewController.m
//  Stolpersteine
//
//  Created by Claus on 04.07.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "WebViewController.h"

#import "TUSafariActivity.h"

@implementation WebViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.webView.scalesPageToFit = YES;
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *title = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    self.navigationItem.title = title;
}

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSArray *itemsToShare = self.itemsToShare.count > 0 ? self.itemsToShare : @[self.url];
    TUSafariActivity *activity = [[TUSafariActivity alloc] init];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:@[activity]];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
