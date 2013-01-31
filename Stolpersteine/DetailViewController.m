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
#import "CopyImageView.h"

#define PADDING 20

@interface DetailViewController()

@property (strong, nonatomic) CopyImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[CopyImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self.scrollView addSubview:self.imageView];

    UIEdgeInsets frameEdgeInsets = UIEdgeInsetsMake(1, 1, 1, 1);
    UIImage *frameImage = [[UIImage imageNamed:@"image-frame.png"] resizableImageWithCapInsets:frameEdgeInsets];
    UIImageView *frameImageView = [[UIImageView alloc] initWithImage:frameImage];
    frameImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.imageView addSubview:frameImageView];
    
    self.imageActivityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.imageActivityIndicator.hidesWhenStopped = TRUE;
    [self.imageView addSubview:self.imageActivityIndicator];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];

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

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat screenWidth;
    if (UIInterfaceOrientationIsPortrait(interfaceOrientation)) {
        screenWidth = UIApplication.sharedApplication.keyWindow.frame.size.width;
    } else {
        screenWidth = UIApplication.sharedApplication.keyWindow.frame.size.height;
    }
    
    self.imageView.frame = CGRectMake(PADDING, PADDING, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
    CGRect imageActivityIndicatorFrame = self.imageActivityIndicator.frame;
    imageActivityIndicatorFrame.origin.x = (self.imageView.frame.size.width - self.imageActivityIndicator.frame.size.width) * 0.5;
    imageActivityIndicatorFrame.origin.y = (self.imageView.frame.size.height - self.imageActivityIndicator.frame.size.height) * 0.5;
    self.imageActivityIndicator.frame = imageActivityIndicatorFrame;
    self.scrollView.contentSize = CGSizeMake(screenWidth, self.imageView.frame.origin.y + self.imageView.frame.size.height + PADDING);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self layoutViewsForInterfaceOrientation:toInterfaceOrientation];
}

@end
