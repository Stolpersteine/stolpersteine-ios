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

#import "StolpersteinAnnotationView.h"

static inline CGPoint TBRectCenter(CGRect rect)
{
    return CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
}

static inline CGRect TBCenterRectRounded(CGRect rect, CGPoint center)
{
    CGRect r = CGRectMake(roundf(center.x - rect.size.width/2.0),
                          roundf(center.y - rect.size.height/2.0),
                          roundf(rect.size.width),
                          roundf(rect.size.height));
    return r;
}

static CGFloat const TBScaleFactorAlpha = 0.3;
static CGFloat const TBScaleFactorBeta = 0.4;

static inline CGFloat TBScaledValueForValue(CGFloat value)
{
    return 1.0 / (1.0 + expf(-1 * TBScaleFactorAlpha * powf(value, TBScaleFactorBeta)));
}

@interface StolpersteinAnnotationView ()

@property (strong, nonatomic) UILabel *countLabel;

@end

@implementation StolpersteinAnnotationView

- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setupLabel];
        [self setCount:1];
        [self setOneLocation:NO];
    }
    return self;
}

- (void)setupLabel
{
    _countLabel = [[UILabel alloc] initWithFrame:self.bounds];
    _countLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.backgroundColor = [UIColor clearColor];
//    _countLabel.textColor = [UIColor colorWithWhite:(35.0/255.0) alpha:1.0];
    _countLabel.textColor = [UIColor whiteColor];
    _countLabel.textAlignment = NSTextAlignmentCenter;
    _countLabel.adjustsFontSizeToFitWidth = YES;
    _countLabel.minimumScaleFactor = 2;
    _countLabel.numberOfLines = 1;
    _countLabel.font = [UIFont boldSystemFontOfSize:12];
    _countLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    
    [self addSubview:_countLabel];
}

- (void)setOneLocation:(BOOL)oneLocation
{
    _oneLocation = oneLocation;
    
    UIImage *image;
    CGPoint centerOffset;
    if (oneLocation) {
        image = [UIImage imageNamed:@"MarkerSquare"];
        centerOffset = CGPointMake(0, -11);
        CGRect frame = self.bounds;
        frame.origin.y -= 1;
        self.countLabel.frame = frame;
        
        self.image = image;
        self.centerOffset = centerOffset;
    } else {
        CGPoint oldCenter = self.center;
        CGRect newBounds = CGRectMake(0, 0, 44 * TBScaledValueForValue(self.count), 44 * TBScaledValueForValue(self.count));
        self.frame = TBCenterRectRounded(newBounds, oldCenter);
        self.center = oldCenter;

        [self setNeedsDisplay];
    }
//    } else {
//        image = [UIImage imageNamed:@"MarkerCircle"];
//        centerOffset = CGPointZero;
//    }
    
//    self.calloutOffset
}

- (void)setCount:(NSUInteger)count
{
    _count = count;
    
    if (!self.isOneLocation) {
        CGPoint oldCenter = self.center;
        CGRect newBounds = CGRectMake(0, 0, 44 * TBScaledValueForValue(count), 44 * TBScaledValueForValue(count));
        self.frame = TBCenterRectRounded(newBounds, oldCenter);
        self.center = oldCenter;
        
        [self setNeedsDisplay];
    }

    self.countLabel.text = [@(count) stringValue];
    
}

- (void)drawRect:(CGRect)rect
{
    if (!self.isOneLocation) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        CGContextSetAllowsAntialiasing(context, true);
        
        UIColor *outerCircleStrokeColor = [UIColor colorWithRed:(35.0 / 255.0) green:(35.0 / 255.0) blue:(35.0 / 255.0) alpha:1.0];
//        UIColor *innerCircleStrokeColor = [UIColor whiteColor];
        UIColor *innerCircleFillColor = [UIColor colorWithRed:(254.0 / 255.0) green:(148.0 / 255.0) blue:(40.0 / 255.0) alpha:1.0];;
        
        CGRect circleFrame = CGRectInset(rect, 4, 4);
        
        [outerCircleStrokeColor setStroke];
        CGContextSetLineWidth(context, 1.0);
        CGContextStrokeEllipseInRect(context, circleFrame);
        
//        [innerCircleStrokeColor setStroke];
//        CGContextSetLineWidth(context, 4);
//        CGContextStrokeEllipseInRect(context, circleFrame);
//        
        [innerCircleFillColor setFill];
        CGContextFillEllipseInRect(context, circleFrame);
    }
}

@end
