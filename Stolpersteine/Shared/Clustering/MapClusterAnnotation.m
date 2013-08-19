//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Copyright (C) 2013 Option-U Software
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "MapClusterAnnotation.h"

#import "MapClusterControllerDelegate.h"

#define fequal(a, b) (fabs((a) - (b)) < FLT_EPSILON)

@implementation MapClusterAnnotation

- (NSString *)title
{
    NSString *title;
    if ([self.delegate respondsToSelector:@selector(mapClusterController:titleForClusterAnnotation:)]) {
        title = [self.delegate mapClusterController:nil titleForClusterAnnotation:self];
    }
    
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle;
    if ([self.delegate respondsToSelector:@selector(mapClusterController:subtitleForClusterAnnotation:)]) {
        subtitle = [self.delegate mapClusterController:nil subtitleForClusterAnnotation:self];
    }

    return subtitle;
}

- (BOOL)isCluster
{
    return (self.annotations.count > 1);
}

- (BOOL)isOneLocation
{
    
    CLLocationCoordinate2D coordinate = kCLLocationCoordinate2DInvalid;
    for (id<MKAnnotation> annotation in self.annotations) {
        if (!CLLocationCoordinate2DIsValid(coordinate) || (fequal(coordinate.latitude, annotation.coordinate.latitude) && fequal(coordinate.longitude, annotation.coordinate.longitude))) {
            coordinate = annotation.coordinate;
        } else {
            coordinate = kCLLocationCoordinate2DInvalid;
            break;
        }
    }
    
    return CLLocationCoordinate2DIsValid(coordinate);
}

@end
