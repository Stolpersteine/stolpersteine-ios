//
//  InfoViewController.m
//  Stolpersteine
//
//  Created by Claus on 26.10.13.
//  Copyright (c) 2013 Option-U Software. All rights reserved.
//

#import "InfoViewController.h"

#import "AppDelegate.h"
#import "DiagnosticsService.h"

@interface InfoViewController ()

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.stolpersteineTextLabel.text = @"Stolpersteine sind kleine Gedenktafeln im Straßenpflaster zur Erinnerung an die Opfer des Nationalsozialismus. Mehr als 40.000 davon hat der Künstler Gunter Demnig mittlerweile in ganz Europa verlegt. Mit dieser App haben Sie schnell und einfach Zugriff auf Orte und Adressen der rund 5.000 Stolpersteinen in Berlin.";
    [self.stolpersteineInfoButton setTitle:@"Stolpersteine auf Wikipedia" forState:UIControlStateNormal];
    [self.artistInfoButton setTitle:@"Gunter Demnigs Webseite" forState:UIControlStateNormal];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [AppDelegate.diagnosticsService trackViewWithClass:self.class];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height;
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        height = 350;
    } else {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == 0) {
        title = @"Stolpersteine";
    } else if (section == 1) {
        title = @"Über die App";
    } else if (section == 2) {
        title = @"Quellenangaben";
    } else if (section == 3) {
        title = @"Danksagungen";
    } else if (section == 4) {
        title = @"Impressum";
    } else {
        title = [super tableView:tableView titleForHeaderInSection:section];
    }
    
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (IBAction)close:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
