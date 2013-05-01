//
//  ViewTransitionSegue.m
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGallerySegue.h"

#import "FullScreenImageGalleryViewController.h"

@implementation FullScreenImageGallerySegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;

    destinationViewController.view.frame = UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds;
    [UIView transitionWithView:sourceViewController.navigationController.view duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        [sourceViewController.view removeFromSuperview];
        [sourceViewController.navigationController.view addSubview:destinationViewController.view];
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {
        [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
    }];
}

@end
