//
//  SearchTextField.h
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchTextField : UITextField<UITextFieldDelegate>

@property (nonatomic, assign, getter = isPortraitModeEnabled) BOOL portraitModeEnabled;

@end
