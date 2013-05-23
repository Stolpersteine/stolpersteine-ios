//
//  ProgressImageView.h
//  Stolpersteine
//
//  Created by Claus on 29.04.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProgressImageView : UIImageView

@property (nonatomic, strong) UIColor *frameColor;  // nil disables frame

- (void)setImageWithURL:(NSURL *)url;
- (void)cancelImageRequest;

@end
