//
//  StolpersteinWrapperAnnotation.m
//  Stolpersteine
//
//  Created by Hoefele, Claus(choefele) on 22.03.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "MapClusteringAnnotation.h"

#import "Stolperstein.h"
#import "Localization.h"

@implementation MapClusteringAnnotation

- (NSString *)title
{
    NSString *title;
    if (self.isCluster) {
        NSUInteger numStolpersteine = MIN(self.stolpersteine.count, 5);
        NSMutableArray *names = [NSMutableArray arrayWithCapacity:numStolpersteine];
        for (Stolperstein *stolperstein in self.stolpersteine) {
            [names addObject:[Localization newShortNameFromStolperstein:stolperstein]];
        }
        title = [names componentsJoinedByString:@", "];
    } else {
        Stolperstein *stolperstein = self.stolpersteine[0];
        title = [Localization newNameFromStolperstein:stolperstein];
    }
    
    return title;
}

- (NSString *)subtitle
{
    NSString *subtitle;
    if (self.isCluster) {
        NSString *titleFormat = NSLocalizedString(@"StolpersteinAnnotation.title", nil);
        subtitle = [NSString stringWithFormat:titleFormat, self.stolpersteine.count];
    } else {
        Stolperstein *stolperstein = self.stolpersteine[0];
        subtitle = [Localization newShortAddressFromStolperstein:stolperstein];
    }
    
    return subtitle;
}

- (BOOL)isCluster
{
    return (self.stolpersteine.count > 1);
}

@end
