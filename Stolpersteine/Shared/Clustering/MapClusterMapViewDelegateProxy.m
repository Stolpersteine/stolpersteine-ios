//
//  MapClusterMapViewDelegateProxy.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 17.09.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusterMapViewDelegateProxy.h"

@interface MapClusterMapViewDelegateProxy()

@property (nonatomic, weak) NSObject<MKMapViewDelegate> *target;
@property (nonatomic, weak) MKMapView *mapView;

@end

@implementation MapClusterMapViewDelegateProxy

- (id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        self.mapView = mapView;
        self.target = mapView.delegate;
        [self swapDelegates];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self.mapView removeObserver:self forKeyPath:@"delegate"];
    [self swapDelegates];
}

- (void)swapDelegates
{
    self.target = self.mapView.delegate;
    self.mapView.delegate = self;
    [self.mapView addObserver:self forKeyPath:@"delegate" options:NSKeyValueObservingOptionNew context:NULL];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    id forwardingTarget;
    
    if ([self.delegate respondsToSelector:selector]) {
        forwardingTarget = self.delegate;
    } else if ([self.target respondsToSelector:selector]) {
        forwardingTarget = self.target;
    } else {
        forwardingTarget = [super forwardingTargetForSelector:selector];
    }
    
    return forwardingTarget;
}

- (BOOL)respondsToSelector:(SEL)selector
{
    BOOL respondsToSelector;
    
    if ([self.delegate respondsToSelector:selector]) {
        respondsToSelector = YES;
    } else if ([self.target respondsToSelector:selector]) {
        respondsToSelector = YES;
    } else {
        respondsToSelector = [super respondsToSelector:selector];
    }
    
    return respondsToSelector;
}

@end
