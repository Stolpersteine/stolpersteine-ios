//
//  StolpersteinAnnotationView.m
//  Stolpersteine
//
//  Created by Claus on 22.08.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinAnnotationView.h"

@implementation StolpersteinAnnotationView

- (id)initWithAnnotation:(id <MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 15, 15);
        self.opaque = NO;
    }
    return self;
}

- (void)setType:(StolpersteinAnnotationViewType)type
{
    _type = type;

    UIImage *image;
    if (type == StolpersteinAnnotationViewTypeSingle) {
        image = [UIImage imageNamed:@"stolperstein-single-5.png"];
    } else if (type == StolpersteinAnnotationViewTypeMultiple) {
        image = [UIImage imageNamed:@"stolperstein-single-5.png"];
    } else if (type == StolpersteinAnnotationViewTypeCluster) {
        image = [UIImage imageNamed:@"stolperstein-single-3.png"];
    }
//    [self setNeedsDisplay];
    self.image = image;
}

- (void)drawRect:(CGRect)rectc
{
//    CGContextRef ctx = UIGraphicsGetCurrentContext();
////    CGContextSetRGBFillColor(context, 1.0, 0.0, 0.0, 1.0);
////    CGContextFillRect(context, self.bounds);
//    
//    CGRect viewBounds = self.bounds;
////    CGContextTranslateCTM(ctx, 0, viewBounds.size.height);
////    CGContextScaleCTM(ctx, 1, -1);
//    CGContextSetRGBFillColor(ctx, 0.0, 0.0, 0.0, 1.0);
//    CGContextSelectFont(ctx, "Helvetica", 10.0, kCGEncodingMacRoman);
//    CGContextShowTextAtPoint(ctx, 0.0, 0.0, "12", 2);
    
    if (_type == StolpersteinAnnotationViewTypeCluster) {
        UIFont *font = [UIFont boldSystemFontOfSize:12];
        NSString *text = @"1213";
        CGRect contextRect = self.bounds;
        
        CGFloat fontHeight = font.pointSize;
        CGFloat yOffset = (contextRect.size.height - fontHeight) * 0.5;
        CGRect textRect = CGRectMake(0, yOffset, contextRect.size.width, fontHeight);
        [text drawInRect:textRect withFont:font lineBreakMode:NSLineBreakByClipping alignment:NSTextAlignmentCenter];
    } else {
        UIImage *image;
        if (_type == StolpersteinAnnotationViewTypeSingle) {
            image = [UIImage imageNamed:@"stolperstein-single.png"];
        } else if (_type == StolpersteinAnnotationViewTypeMultiple) {
            image = [UIImage imageNamed:@"stolperstein-multiple-1.png"];
        }
        
        [image drawAtPoint:CGPointZero];
    }
}

@end
