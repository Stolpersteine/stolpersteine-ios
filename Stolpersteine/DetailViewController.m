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
#import "CopyableImageView.h"

#define PADDING 20

@interface DetailViewController()

@property (strong, nonatomic) CopyableImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;

@end

@implementation DetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.imageView = [[CopyableImageView alloc] initWithFrame:CGRectMake(0, 0, 3, 3)];
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
    
    self.title = self.stolperstein.title;
    if (self.stolperstein.imageURLString) {
        [self loadImageWithURLString:self.stolperstein.imageURLString];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.stolperstein.imageURLString forKey:@"stolperstein.imageURLString"];
    [coder encodeObject:self.title forKey:@"title"];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder
{
    NSString *imageURLString = [coder decodeObjectForKey:@"stolperstein.imageURLString"];
    if (imageURLString) {
        [self loadImageWithURLString:imageURLString];
    }
    self.title = [coder decodeObjectForKey:@"title"];

    [super decodeRestorableStateWithCoder:coder];
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

- (void)loadImageWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
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

- (void)layoutViewsForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    CGFloat screenWidth = self.view.frame.size.width;
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

- (IBAction)showActivities:(UIBarButtonItem *)sender
{
    NSMutableArray *itemsToShare = [NSMutableArray arrayWithObject:self.title];
    if (self.imageView.image) {
        [itemsToShare addObject:self.imageView.image];
    }
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:itemsToShare applicationActivities:nil];
    activityViewController.excludedActivityTypes = @[UIActivityTypeAssignToContact];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

@end
