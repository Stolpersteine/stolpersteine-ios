//
//  RoundedRectButton.m
//  Stolpersteine
//
//  Created by Claus on 30.06.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "RoundedRectButton.h"

@implementation RoundedRectButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)setup
{
    UIImage *backgroundImage = [[UIImage imageNamed:@"rounded-rect-frame.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(8, 8, 8, 8)];
    [self setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [self setTitleColor:UIColor.blackColor forState:UIControlStateNormal];
}

- (void)setChevronEnabled:(BOOL)chevronEnabled
{
    _chevronEnabled = chevronEnabled;
    
    UIImage *image = chevronEnabled ? [UIImage imageNamed:@"icon-chevron.png"] : nil;
    [self setImage:image forState:UIControlStateNormal];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    
    if (self.isChevronEnabled) {
        UIImage *image = [self imageForState:UIControlStateNormal];
        self.imageEdgeInsets = UIEdgeInsetsMake(0, bounds.size.width - 30, 0, 0);
        self.titleEdgeInsets = UIEdgeInsetsMake(0, -image.size.width, 0, 0);
    } else {
        self.imageEdgeInsets = UIEdgeInsetsZero;
        self.titleEdgeInsets = UIEdgeInsetsZero;
    }
}

@end
