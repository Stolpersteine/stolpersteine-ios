//
//  DetailViewController.m
//  Stolpersteine
//
//  Created by Claus on 16.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinDetailViewController.h"

#import "Stolperstein.h"
#import "UIImageView+AFNetworking.h"
#import "CopyableImageView.h"

#define PADDING 20

@interface StolpersteinDetailViewController()

@property (strong, nonatomic) CopyableImageView *imageView;
@property (strong, nonatomic) UIActivityIndicatorView *imageActivityIndicator;
@property (strong, nonatomic) UILabel *addressLabel;

@end

@implementation StolpersteinDetailViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Image
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
    
    if (self.stolperstein.imageURLString) {
        [self loadImageWithURLString:self.stolperstein.imageURLString];
    }
    
    // Address
    NSMutableString *address = [NSMutableString stringWithCapacity:20];
    
    if (self.stolperstein.locationStreet) {
        [address appendString:self.stolperstein.locationStreet];
    }
    
    if (self.stolperstein.locationZipCode || self.stolperstein.locationCity) {
        [address appendString:@"\n"];
        
        if (self.stolperstein.locationZipCode) {
            [address appendFormat:@"%@", self.stolperstein.locationZipCode];
        }
        if (self.stolperstein.locationCity) {
            [address appendFormat:@" %@", self.stolperstein.locationCity];
        }
    }
    NSAttributedString *addressText = [[NSAttributedString alloc] initWithString:address];
    self.addressLabel = [[UILabel alloc] init];
    self.addressLabel.attributedText = addressText;
    self.addressLabel.numberOfLines = INT_MAX;
    [self.scrollView addSubview:self.addressLabel];

    // Title
    self.title = self.stolperstein.title;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self layoutViewsForInterfaceOrientation:self.interfaceOrientation];
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

- (void)loadImageWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:URL];
    [self.imageActivityIndicator startAnimating];
    
    __weak StolpersteinDetailViewController *weakSelf = self;
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
    
    // Image
    self.imageView.frame = CGRectMake(PADDING, PADDING, screenWidth - 2 * PADDING, screenWidth - 2 * PADDING);
    CGRect imageActivityIndicatorFrame = self.imageActivityIndicator.frame;
    imageActivityIndicatorFrame.origin.x = (self.imageView.frame.size.width - self.imageActivityIndicator.frame.size.width) * 0.5;
    imageActivityIndicatorFrame.origin.y = (self.imageView.frame.size.height - self.imageActivityIndicator.frame.size.height) * 0.5;
    self.imageActivityIndicator.frame = imageActivityIndicatorFrame;
    
    // Address
    CGRect addressFrame;
    addressFrame.origin.x = PADDING;
    addressFrame.origin.y = self.imageView.frame.origin.y + self.imageView.frame.size.height + PADDING * 0.5;
    addressFrame.size = [self.addressLabel sizeThatFits:CGSizeMake(screenWidth - 2 * PADDING, FLT_MAX)];
    self.addressLabel.frame = addressFrame;
    
    // Scroll view
    self.scrollView.contentSize = CGSizeMake(screenWidth, self.addressLabel.frame.origin.y + self.addressLabel.frame.size.height + PADDING);
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
