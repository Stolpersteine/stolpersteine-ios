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

#define PADDING 20

@interface DetailViewController()

@property (strong, nonatomic) UIImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[UIImageView alloc] init];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];
    
    [self layoutSubviewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.title = self.stolperstein.title;
    if (self.stolperstein.imageURLString && !self.imageView.image) {
        NSURL *URL = [NSURL URLWithString:self.stolperstein.imageURLString];
        NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
        [self.imageActivityIndicator startAnimating];
        
        __weak DetailViewController *weakSelf = self;
        [self.imageView setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            weakSelf.imageView.image = image;
            [weakSelf.imageActivityIndicator stopAnimating];
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [weakSelf.imageActivityIndicator stopAnimating];
        }];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.imageView cancelImageRequestOperation];
}

- (void)viewDidUnload
{
    [self setImageView:nil];
    [self setImageActivityIndicator:nil];
    [self setScrollView:nil];

    [super viewDidUnload];
}

- (void)layoutSubviewsForInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    CGFloat screenWidth;
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        screenWidth = UIApplication.sharedApplication.keyWindow.frame.size.width;
    } else {
        screenWidth = UIApplication.sharedApplication.keyWindow.frame.size.height;
    }
    
    self.imageView.frame = CGRectMake(PADDING, PADDING, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
    self.scrollView.contentSize = CGSizeMake(screenWidth, self.imageView.frame.origin.y + self.imageView.frame.size.height + PADDING);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutSubviewsForInterfaceOrientation:toInterfaceOrientation];
}

@end
