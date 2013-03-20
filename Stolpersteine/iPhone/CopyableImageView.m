//
//  CopyImageView.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 31.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "CopyableImageView.h"

@implementation CopyableImageView

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
    self.userInteractionEnabled = YES;
    UIGestureRecognizer *touchy = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer:touchy];
}

- (void)copy:(id)sender
{
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    NSData *data = [NSData dataWithData:UIImagePNGRepresentation(self.image)];
    [pasteboard setData:data forPasteboardType:@"public.jpeg"];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)handleTap:(UIGestureRecognizer *)recognizer
{
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if (!menu.isMenuVisible) {
        [self becomeFirstResponder];
        [menu setTargetRect:self.frame inView:self.superview];
        [menu setMenuVisible:YES animated:YES];
    }
}

@end
