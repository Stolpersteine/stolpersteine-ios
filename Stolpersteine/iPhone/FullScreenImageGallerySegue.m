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
    [UIView transitionWithView:sourceViewController.navigationController.view duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionAllowUserInteraction animations:^(void) {
        [sourceViewController.view removeFromSuperview];
        [sourceViewController.navigationController.view addSubview:destinationViewController.view];
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } completion:^(BOOL finished) {
        if (finished) {
            [sourceViewController presentViewController:destinationViewController animated:NO completion:NULL];
        } else {
            NSLog(@"canceled");
        }
    }];
    
    // Animations to dismiss the view controller
    destinationViewController.completionBlock = ^() {
        [sourceViewController.navigationController.view.layer removeAllAnimations];
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [sourceViewController dismissViewControllerAnimated:YES completion:NULL];
    };
}

@end
