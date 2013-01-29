//
//  DetailViewController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "DetailViewController.h"

#import "Stolperstein.h"
#import "UIImageView+AFNetworking.h"

@implementation DetailViewController

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.stolperstein.title;
    if (self.stolperstein.imageURLString && !self.imageView.image) {
        NSURL *URL = [NSURL URLWithString:self.stolperstein.imageURLString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
        [self.imageActivityIndicator startAnimating];
        [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            self.imageView.image = image;
            [self.imageActivityIndicator stopAnimating];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [self.imageActivityIndicator stopAnimating];
        }];
    }
    
    CGFloat height = 2 * self.imageView.frame.origin.y + self.imageView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView cancelImageRequestOperation];
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setImageView:nil];
    [self setImageActivityIndicator:nil];
    [self setScrollView:nil];
    [super viewDidUnload];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGRect frame = self.imageView.frame;
    frame.size.height = UIInterfaceOrientationIsPortrait(toInterfaceOrientation) ? 280 : 440;
    self.imageView.frame = frame;
    
    CGFloat height = 2 * self.imageView.frame.origin.y + self.imageView.frame.size.height;
    self.scrollView.contentSize = CGSizeMake(self.view.frame.size.width, height);
}

@end
