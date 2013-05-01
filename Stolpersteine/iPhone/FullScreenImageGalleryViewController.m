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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
    }
    return self;
}

- (IBAction)done:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
