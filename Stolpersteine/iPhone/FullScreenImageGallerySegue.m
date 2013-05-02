//
//  ViewTransitionSegue.m
//  Stolpersteine
//
//  Created by Claus on 01.05.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "FullScreenImageGallerySegue.h"

#import "FullScreenImageGalleryViewController.h"

#import <QuartzCore/QuartzCore.h>

@implementation FullScreenImageGallerySegue

- (void)perform
{
    UIViewController *sourceViewController = self.sourceViewController;
    FullScreenImageGalleryViewController *destinationViewController = self.destinationViewController;

    // Animations to present the view controller
    destinationViewController.view.frame = UIApplication.sharedApplication.keyWindow.rootViewController.view.bounds;
    [UIView transitionWithView:sourceViewController.navigationController.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        [sourceViewController.view removeFromSuperview];
        [sourceViewController.navigationController.view addSubview:destinationViewController.view];
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {
        [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
    }];
    
    // Animations to dismiss the view controller
    __weak FullScreenImageGalleryViewController *weakDestinationViewController = self.destinationViewController;
    destinationViewController.completionBlock = ^() {
        weakDestinationViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [sourceViewController dismissViewControllerAnimated:YES completion:NULL];
    };
}

@end
