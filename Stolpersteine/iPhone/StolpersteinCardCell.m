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
#import "CCHLinkTextView.h"
#import "CCHLinkTextViewDelegate.h"

@interface StolpersteinCardCell () <UIActionSheetDelegate, CCHLinkTextViewDelegate>

@property (weak, nonatomic) IBOutlet CCHLinkTextView *bodyTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;

@property (nonatomic, strong) Stolperstein *stolperstein;

@end

@implementation StolpersteinCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
}

- (void)setUp
{
    self.bodyTextView.linkDelegate = self;
    
//    // Copy & paste
//    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
//    [self addGestureRecognizer:recognizer];
//    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (void)updateWithStolperstein:(Stolperstein *)stolperstein streetButtonHidden:(BOOL)streetButtonHidden index:(NSUInteger)index
{
    self.stolperstein = stolperstein;
    self.bodyTextView.attributedText = [StolpersteinCardCell newBodyAttributedStringFromStolperstein:stolperstein streetButtonHidden:streetButtonHidden];
    
    if ([self canSelectCurrentStolperstein]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (BOOL)canSelectCurrentStolperstein
{
    BOOL canSelectRow = (self.stolperstein.personBiographyURLString.length > 0);
    return canSelectRow;
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

- (CGFloat)heightForCurrentStolpersteinWithTableViewWidth:(CGFloat)width
{
    width -= self.accessoryType == UITableViewCellAccessoryNone ? 0 : 33;   // accessory view
    CGSize size = [self.bodyTextView sizeThatFits:CGSizeMake(width, FLT_MAX)];
    CGFloat height = ceil(size.height);
    height += 1;    // cell separator
    return height;
}

+ (NSAttributedString *)newBodyAttributedStringFromStolperstein:(Stolperstein *)stolperstein streetButtonHidden:(BOOL)streetButtonHidden
{
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    NSString *body = [NSString stringWithFormat:@"%@\n%@", name, address];
    NSMutableAttributedString *bodyAttributedString = [[NSMutableAttributedString alloc] initWithString:body];
    
    [bodyAttributedString beginEditing];
    
    UIFont *nameFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    NSRange nameRange = NSMakeRange(0, name.length);
    [bodyAttributedString addAttribute:NSFontAttributeName value:nameFont range:nameRange];
    
    UIFont *addressFont = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
    NSRange addressRange = NSMakeRange(nameRange.length + 1, address.length);
    [bodyAttributedString addAttribute:NSFontAttributeName value:addressFont range:addressRange];
    
    NSString *streetName = [Localization newStreetNameFromStolperstein:stolperstein];
    NSRange streetNameRange = NSMakeRange(nameRange.length + 1, streetName.length);
    [bodyAttributedString addAttribute:NSLinkAttributeName value:@"http://google.de" range:streetNameRange];
    
    [bodyAttributedString endEditing];
    
    return bodyAttributedString;
}

#pragma mark Link handling

- (void)linkTextViewDidTap:(CCHLinkTextView *)linkTextView
{
    NSIndexPath *indexPath = [self.tableView indexPathForCell:self];
    if ([self.tableView.delegate respondsToSelector:@selector(tableView:willSelectRowAtIndexPath:)]) {
        [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:indexPath];
    }
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    if ([self.tableView.delegate respondsToSelector:@selector(tableView:didSelectRowAtIndexPath:)]) {
        [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
    }
}

#pragma mark Copy & paste

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

- (void)willHideEditMenu:(NSNotification *)notification
{
    [self setSelected:NO animated:NO];
}

@end
