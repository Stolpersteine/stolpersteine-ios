//
//  FullScreenImagGalleryViewController.m
//  Stolpersteine
//
//  Created by Claus on 30.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGalleryViewController.h"

#import "AppDelegate.h"
#import "DiagnosticsService.h"

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
    [self.view addGestureRecognizer:tapGestureRecognizer];
    self.view.userInteractionEnabled = YES;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewController:self];
}

- (void)done
{
    if (self.completionBlock) {
        self.completionBlock();
    }
}

@end
