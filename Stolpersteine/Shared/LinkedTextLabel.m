//
//  LinkedTextLabel.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "LinkedTextLabel.h"

@interface LinkedTextLabel()

@property (nonatomic, strong) UITextView *textView;

@end

@implementation LinkedTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.textView];
        self.textView.editable = FALSE;
        self.textView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.textView.text = @"Source: Kooperationsstelle Stolpersteine Berlin";
        self.textView.font = [UIFont systemFontOfSize:UIFont.labelFontSize - 4];

        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        [self.textView addGestureRecognizer:recognizer];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGSize sizeThatFits = [self.textView sizeThatFits:size];
    return CGSizeMake(sizeThatFits.width + self.textView.contentInset.left + self.textView.contentInset.right, sizeThatFits.height + self.textView.contentInset.top + self.textView.contentInset.bottom);
}

- (void)handleTap:(UITapGestureRecognizer *)sender
{
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self.textView];
        UITextRange *range = [self.textView characterRangeAtPoint:point];
        NSLog(@"handleTap %@", [self.textView textInRange:range]);
    }
}

@end
