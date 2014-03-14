//
//  CCHMapsActivity.h
//  CCHMapsActivity
//
//  Copyright (C) 2013 Claus Höfele
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

#import "CCHMapsActivity.h"

#import <MapKit/MapKit.h>

@interface CCHMapsActivity()

@property (nonatomic, strong) MKMapItem *mapItem;

@end

@implementation CCHMapsActivity

- (NSString *)activityType
{
    return NSStringFromClass(self.class);
}

- (NSString *)activityTitle
{
    return NSLocalizedStringFromTable(@"activity.openMaps", @"CCHMapsActivity", nil);
}

- (UIImage *)activityImage
{
    return [UIImage imageNamed:@"CCHMapsActivity.png"];
}

- (BOOL)canPerformWithActivityItems:(NSArray *)activityItems
{
    BOOL result = NO;
    
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:MKMapItem.class]) {
            result = YES;
            break;
        }
    }

    return result;
}

- (void)prepareWithActivityItems:(NSArray *)activityItems
{
    for (id activityItem in activityItems) {
        if ([activityItem isKindOfClass:MKMapItem.class]) {
            self.mapItem = activityItem;
            break;
        }
    }
}

- (void)performActivity
{
    BOOL result = [self.mapItem openInMapsWithLaunchOptions:self.launchOptions];
    [self activityDidFinish:result];
}

@end
