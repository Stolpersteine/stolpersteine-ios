//
//  FullScreenImagGalleryViewController.m
//  Stolpersteine
//
//  Created by Claus on 30.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGalleryViewController.h"

@interface FullScreenImageGalleryViewController ()

@end

@implementation FullScreenImageGalleryViewController

- (void)awakeFromNib
{
    self.view.backgroundColor = UIColor.blackColor;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(done)];
    self.view.userInteractionEnabled = YES;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)done
{
    [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
