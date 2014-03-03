//
//  TextView.m
//  Stolpersteine
//
//  Created by Claus Höfele on 03.03.14.
//  Copyright (c) 2014 Option-U Software. All rights reserved.
//

#import "TextView.h"

@implementation TextView

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegan");
    [super touchesBegan:touches withEvent:event];
    
    CGPoint tapLocation = [touches.anyObject locationInView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:tapLocation];

//    [self.tableView.delegate tableView:self.tableView willSelectRowAtIndexPath:indexPath];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    [self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:indexPath];
}

@end
