//
//  MapClusteringControllerUtils.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 21.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringControllerUtils.h"

id<MKAnnotation> MapClusteringControllerFindClosestAnnotation(NSSet *annotations, MKMapPoint mapPoint)
{
    id<MKAnnotation> closestAnnotation;
    CLLocationDistance closestDistance = DBL_MAX;
    for (id<MKAnnotation> annotation in annotations) {
        MKMapPoint annotationAsMapPoint = MKMapPointForCoordinate(annotation.coordinate);
        CLLocationDistance distance = MKMetersBetweenMapPoints(mapPoint, annotationAsMapPoint);
        if (distance < closestDistance) {
            closestDistance = distance;
            closestAnnotation = annotation;
        }
    }
    
    return closestAnnotation;
}