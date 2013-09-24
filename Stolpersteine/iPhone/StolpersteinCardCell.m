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

#define PADDING 16
#define WIDTH 288

@interface StolpersteinCardCell()

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
}

- (void)updateWithStolperstein:(Stolperstein *)stolperstein
{
    self.stolperstein = stolperstein;
    self.titleLabel.attributedText = [StolpersteinCardCell newAttributedStringFromStolperstein:stolperstein];
}

+ (CGFloat)standardHeight
{
    Stolperstein *stolperstein = [[Stolperstein alloc] init];
    stolperstein.personFirstName = @"xxxxxxxxxx";
    stolperstein.personLastName = @"xxxxxxxxxx";
    stolperstein.locationStreet = @"xxxxxxxxxx xxx";
    stolperstein.locationZipCode = @"xxxx";
    stolperstein.locationCity = @"xxxxxxxxxx";
    
    NSAttributedString *attributedText = [StolpersteinCardCell newAttributedStringFromStolperstein:stolperstein];
    CGRect boundingRect = [attributedText boundingRectWithSize:CGSizeMake(WIDTH, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    
    return ceil(boundingRect.size.height) + 2 * PADDING;
}

+ (NSAttributedString *)newAttributedStringFromStolperstein:(Stolperstein *)stolperstein
{
    NSString *name = [Localization newNameFromStolperstein:stolperstein];
    NSString *address = [Localization newLongAddressFromStolperstein:stolperstein];
    NSString *detailText = [NSString stringWithFormat:@"%@\n%@", name, address];
    NSMutableAttributedString *attributedDetailText = [[NSMutableAttributedString alloc] initWithString:detailText];
    
    [attributedDetailText beginEditing];
    
    UIFont *nameFont = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    NSRange nameRange = NSMakeRange(0, name.length);
    [attributedDetailText addAttribute:NSFontAttributeName value:nameFont range:nameRange];
    
    UIFont *addressFont = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    NSRange addressRange = NSMakeRange(nameRange.length + 1, address.length);
    [attributedDetailText addAttribute:NSFontAttributeName value:addressFont range:addressRange];
    
    [attributedDetailText endEditing];
    
    return attributedDetailText;
}

@end
