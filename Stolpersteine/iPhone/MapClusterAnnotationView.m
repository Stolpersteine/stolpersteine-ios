//
//  StolpersteinClusterAnnotationView.m
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

#import "MapClusterAnnotationView.h"

#define FOREGROUND_COLOR [UIColor colorWithWhite:(244.0 / 255.0) alpha:1.0]

@interface MapClusterAnnotationView ()

@property (nonatomic) UILabel *countLabel;

@end

@implementation MapClusterAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setUpLabel];
        _oneLocation = NO;
        self.count = 1;
    }
    return self;
}

- (void)setUpLabel
{
    UILabel *countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.backgroundColor = [UIColor clearColor];
    countLabel.textColor = FOREGROUND_COLOR;
    countLabel.textAlignment = NSTextAlignmentCenter;
    countLabel.adjustsFontSizeToFitWidth = YES;
    countLabel.minimumScaleFactor = 2;
    countLabel.numberOfLines = 1;
    countLabel.font = [UIFont boldSystemFontOfSize:12];
    countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    self.countLabel = countLabel;
    
    [self addSubview:countLabel];
}

- (void)setOneLocation:(BOOL)oneLocation
{
    _oneLocation = oneLocation;
    
    [self setNeedsLayout];
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    self.countLabel.text = [@(count) stringValue];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    UIImage *image;
    CGPoint centerOffset;
    if (self.oneLocation) {
        image = [UIImage imageNamed:@"MarkerSquare"];
        centerOffset = CGPointMake(0, image.size.height * 0.5);
        CGRect frame = self.bounds;
        frame.origin.y -= 2;
        self.countLabel.frame = frame;
    } else {
        centerOffset = CGPointZero;
        self.countLabel.frame = self.bounds;
        
        if (self.count > 999) {
            image = [UIImage imageNamed:@"MarkerCircle94"];
        } else if (self.count > 499) {
            image = [UIImage imageNamed:@"MarkerCircle90"];
        } else if (self.count > 99) {
            image = [UIImage imageNamed:@"MarkerCircle84"];
        } else if (self.count > 9) {
            image = [UIImage imageNamed:@"MarkerCircle62"];
        } else {
            image = [UIImage imageNamed:@"MarkerCircle52"];
        }
    }
    
    self.image = image;
    self.centerOffset = centerOffset;
}

@end
