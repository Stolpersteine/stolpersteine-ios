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
    if (self.stolperstein.imageURLString) {
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
}

- (void)viewDidUnload
{
    [self setNameLabel:nil];
    [self setImageView:nil];
    [self setImageActivityIndicator:nil];
    [super viewDidUnload];
}
@end
