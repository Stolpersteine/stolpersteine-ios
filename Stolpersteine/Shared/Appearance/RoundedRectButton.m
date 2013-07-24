//
//  RoundedRectButton.m
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
