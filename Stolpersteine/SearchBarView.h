//
//  SearchBarView.h
//  Stolpersteine
//
//  Created by Claus on 24.01.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SearchBarViewDelegate;

@interface SearchBarView : UIView

@property (nonatomic, assign, getter = isPortraitModeEnabled) BOOL portraitModeEnabled;
@property (nonatomic, weak) NSObject<SearchBarViewDelegate> *delegate;

@end
