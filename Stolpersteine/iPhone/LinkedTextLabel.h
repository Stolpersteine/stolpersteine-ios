//
//  LinkedTextLabel.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LinkedTextLabel : UIView

@property (nonatomic, copy) NSAttributedString *attributedText;

- (void)setLink:(NSURL *)link range:(NSRange)range;

@end
