//
//  StolpersteinCardsCell.m
//  Stolpersteine
//
//  Created by Claus on 19.09.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "StolpersteinCardCell.h"

#import "Stolperstein.h"
#import "Localization.h"

@interface StolpersteinCardCell()<UIActionSheetDelegate>

@property (nonatomic, strong) Stolperstein *stolperstein;

@end

@implementation StolpersteinCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setup];
}

- (void)prepareForReuse
{
    [super prepareForReuse];
    
    [self setup];
}

- (void)setup
{
    NSString *title = NSLocalizedString(@"StolpersteinCardCell.street", nil);
    [self.streetButton setTitle:title forState:UIControlStateNormal];
    
    // Long press for copy & paste
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [self addGestureRecognizer:recognizer];
}

- (void)updateWithStolperstein:(Stolperstein *)stolperstein streetButtonHidden:(BOOL)streetButtonHidden
{
    self.stolperstein = stolperstein;
    self.bodyLabel.attributedText = [StolpersteinCardCell newBodyAttributedStringFromStolperstein:stolperstein];
    
    if (streetButtonHidden) {
        [self.streetButton removeFromSuperview];
    }
}

+ (Stolperstein *)standardStolperstein
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.personFirstName = @"xxxxxxxxxx";
    stolperstein.personLastName = @"xxxxxxxxxx";
    stolperstein.locationStreet = @"xxxxxxxxxx xxx";
    stolperstein.locationZipCode = @"xxxx";
    stolperstein.locationCity = @"xxxxxxxxxx";

    return stolperstein;
}

- (void)updateLayoutWithTableView:(UITableView *)tableView
{
    CGFloat left = self.leftSpaceConstraint.constant;
    CGFloat right = self.rightSpaceConstraint.constant;
    CGFloat width = tableView.bounds.size.width - left - right;
    self.bodyLabel.preferredMaxLayoutWidth = width;
}

- (CGFloat)heightForCurrentStolperstein
{
    [self setNeedsUpdateConstraints];
    [self updateConstraintsIfNeeded];
    [self.contentView setNeedsLayout];
    [self.contentView layoutIfNeeded];
    
    CGFloat height = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return height;
}

+ (NSAttributedString *)newBodyAttributedStringFromStolperstein:(Stolperstein *)stolperstein
{
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    NSString *body = [NSString stringWithFormat:@"%@\n%@", name, address];
    NSMutableAttributedString *bodyAttributedString = [[NSMutableAttributedString alloc] initWithString:body];
    
    [bodyAttributedString beginEditing];
    
    UIFont *nameFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    NSRange nameRange = NSMakeRange(0, name.length);
    [bodyAttributedString addAttribute:NSFontAttributeName value:nameFont range:nameRange];
    
    UIFont *addressFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSRange addressRange = NSMakeRange(nameRange.length + 1, address.length);
    [bodyAttributedString addAttribute:NSFontAttributeName value:addressFont range:addressRange];
    
    [bodyAttributedString endEditing];
    
    return bodyAttributedString;
}

#pragma mark Copy & paste related methods

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    if (action == @selector(copy:)) {
        return YES;
    }
    
    return [super canPerformAction:action withSender:sender];
}

- (void)copy:(id)sender
{
    Stolperstein *stolperstein = self.stolperstein;
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    pasteboard.URL = [NSURL URLWithString:stolperstein.personBiographyURLString];
    pasteboard.string = [Localization newPasteboardStringFromStolperstein:stolperstein];
    
    [self setSelected:NO animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark UILongPressGestureRecognizer handler methods

- (void)handleLongPress:(UILongPressGestureRecognizer *)longPressRecognizer
{
    if (longPressRecognizer.state != UIGestureRecognizerStateBegan) {
        return;
    }

    [self becomeFirstResponder];    // has to be before setMenuVisible:animated:
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible:YES animated:YES];
    
    [self setSelected:YES animated:NO];
}

@end
