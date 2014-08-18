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
#import "CCHLinkGestureRecognizer.h"

@interface StolpersteinCardCell () <UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet CCHLinkTextView *bodyTextView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *rightConstraint;

@property (nonatomic, copy) Stolperstein *stolperstein;

@end

@implementation StolpersteinCardCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    [self setUp];
}

- (void)setUp
{
    self.bodyTextView.textContainer.lineFragmentPadding = 15;
    
    // Copy & paste
    UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    [recognizer requireGestureRecognizerToFail:self.bodyTextView.linkGestureRecognizer];
    [self addGestureRecognizer:recognizer];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(willHideEditMenu:) name:UIMenuControllerWillHideMenuNotification object:nil];
}

- (void)dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (id<CCHLinkTextViewDelegate>)linkDelegate
{
    return self.bodyTextView.linkDelegate;
}

- (void)setLinkDelegate:(id<CCHLinkTextViewDelegate>)linkDelegate
{
    self.bodyTextView.linkDelegate = linkDelegate;
}

- (void)updateWithStolperstein:(Stolperstein *)stolperstein linksDisabled:(BOOL)linksDisabled index:(NSUInteger)index
{
    self.stolperstein = stolperstein;
    self.bodyTextView.attributedText = [StolpersteinCardCell newBodyAttributedStringFromStolperstein:stolperstein linksDisabled:linksDisabled];
    
    if ([self canSelectCurrentStolperstein]) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        self.accessoryType = UITableViewCellAccessoryNone;
    }
}

- (BOOL)canSelectCurrentStolperstein
{
    BOOL canSelectRow = (self.stolperstein.personBiographyURL != nil);
    return canSelectRow;
}

+ (Stolperstein *)standardStolperstein
{
    Stolperstein *stolperstein = [Stolperstein stolpersteinWithBuilderBlock:^(StolpersteinComponents *builder) {
        builder.personFirstName = @"xxxxxxxxxx";
        builder.personLastName = @"xxxxxxxxxx";
        builder.locationStreet = @"xxxxxxxxxx xxx";
        builder.locationZipCode = @"xxxx";
        builder.locationCity = @"xxxxxxxxxx";
    }];

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

+ (NSAttributedString *)newBodyAttributedStringFromStolperstein:(Stolperstein *)stolperstein linksDisabled:(BOOL)linksDisabled
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
    
    if (!linksDisabled) {
        NSString *streetName = [Localization newStreetNameFromStolperstein:stolperstein];
        NSRange streetNameRange = NSMakeRange(name.length + 1, streetName.length);
        [bodyAttributedString addAttribute:CCHLinkAttributeName value:@"" range:streetNameRange];
    }
    
    [bodyAttributedString endEditing];
    
    return bodyAttributedString;
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
    UIPasteboard *pasteboard = UIPasteboard.generalPasteboard;
    NSURL *URL = [Localization newPersonBiographyURLFromStolperstein:self.stolperstein];
    if (URL) {
        pasteboard.URL = [Localization newPersonBiographyURLFromStolperstein:self.stolperstein];
    }
    pasteboard.string = [Localization newPasteboardStringFromStolperstein:self.stolperstein];
    
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
