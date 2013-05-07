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
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    UIViewController *rootViewController = window.rootViewController;

    // Animations to present the view controller
    destinationViewController.view.frame = rootViewController.view.bounds;
    [UIView transitionWithView:window duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
        // Animate view controller transition
        window.rootViewController = destinationViewController;
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    } completion:NULL];

    // View animations
//    CGRect windowFrame = [window convertRect:self.animationView.frame fromView:self.animationView.superview];
//    [window addSubview:self.animationView];
//    self.animationView.frame = windowFrame;
//    [UIView animateWithDuration:2 animations:^{
//        self.animationView.transform = CGAffineTransformMakeTranslation(100, 100);
//    }];
    
    // Animations to dismiss the view controller
    __weak FullScreenImageGalleryViewController *weakDestinationViewController = self.destinationViewController;
    destinationViewController.completionBlock = ^() {
        FullScreenImageGalleryViewController *strongDestinationViewController = weakDestinationViewController;
        
        // Forward current interface orientation to offscreen view controller
        [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        window.rootViewController = rootViewController;
        [sourceViewController willRotateToInterfaceOrientation:strongDestinationViewController.interfaceOrientation duration:0];
        [sourceViewController willAnimateRotationToInterfaceOrientation:strongDestinationViewController.interfaceOrientation duration:0];
        [sourceViewController didRotateFromInterfaceOrientation:strongDestinationViewController.interfaceOrientation];
        window.rootViewController = strongDestinationViewController;
        [UIApplication.sharedApplication setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

        // Animate view controller transition
        [UIView transitionWithView:UIApplication.sharedApplication.keyWindow duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve animations:^(void) {
            [UIApplication.sharedApplication setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            window.rootViewController = rootViewController;
        } completion:NULL];
    };
}

@end
