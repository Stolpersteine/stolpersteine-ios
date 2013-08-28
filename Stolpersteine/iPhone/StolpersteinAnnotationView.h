//
//  StolpersteinAnnotationView.h
//  Stolpersteine
//
//  Created by Claus on 22.08.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <MapKit/MapKit.h>

typedef enum {
    StolpersteinAnnotationViewTypeSingle,
    StolpersteinAnnotationViewTypeMultiple,
    StolpersteinAnnotationViewTypeCluster
} StolpersteinAnnotationViewType;

@interface StolpersteinAnnotationView : MKAnnotationView

@property (nonatomic, assign) StolpersteinAnnotationViewType type;
@property (nonatomic, assign) NSUInteger numberOfItems;

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier;

@end
