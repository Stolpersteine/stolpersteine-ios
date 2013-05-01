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
@property (nonatomic, strong) NSMutableDictionary *links;

@end

@implementation LinkedTextLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.textView.editable = FALSE;
        self.textView.userInteractionEnabled = FALSE;
        self.textView.contentInset = UIEdgeInsetsMake(-8, -8, -8, -8);
        self.textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.textView];
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        recognizer.numberOfTapsRequired = 1;
        recognizer.numberOfTouchesRequired = 1;
        [self addGestureRecognizer:recognizer];
        
        self.links = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

- (void)setAttributedText:(NSAttributedString *)attributedText
{
    // Fixes alignment issue when using attributedText
    self.textView.text = nil;
    self.textView.font = nil;
    self.textView.textColor = nil;
    self.textView.textAlignment = NSTextAlignmentLeft;

    self.textView.attributedText = attributedText;
}

- (NSAttributedString *)attributedText
{
    return self.textView.attributedText;
}

- (void)setLink:(NSURL *)link range:(NSRange)range
{
    [self.links setObject:link forKey:NSStringFromRange(range)];
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
        
        NSURL *url;
        if (range && !range.empty) {
            NSInteger startOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.start];
            NSInteger endOffset = [self.textView offsetFromPosition:self.textView.beginningOfDocument toPosition:range.end];
            NSRange rangeTap = NSMakeRange(startOffset, endOffset - startOffset);
            
            for (NSString *rangeAsString in self.links.allKeys) {
                NSRange rangeLink = NSRangeFromString(rangeAsString);
                NSRange intersection = NSIntersectionRange(rangeTap, rangeLink);
                BOOL intersect = (intersection.length != 0);
                if (intersect) {
                    url = [self.links valueForKey:rangeAsString];
                    break;
                }
            }
            
            if (url) {
                [UIApplication.sharedApplication openURL:url];
            }
        }
    }
}

@end
