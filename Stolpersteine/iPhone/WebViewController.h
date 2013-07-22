//
//  WebViewController.h
//  Stolpersteine
//
//  Created by Claus on 04.07.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebViewController : UIViewController<UIWebViewDelegate>

@property (nonatomic, strong) NSURL *url;
@property (nonatomic, strong) NSArray *itemsToShare;

@property (weak, nonatomic) IBOutlet UIWebView *webView;

- (IBAction)showActivities:(UIBarButtonItem *)sender;

@end
