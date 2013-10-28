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
    
    self.title = NSLocalizedString(@"InfoViewController.title", nil);
    
	// Stolpersteine
    self.stolpersteineLabel.text = @"Stolpersteine sind kleine Gedenktafeln im Straßenpflaster zur Erinnerung an die Opfer des Nationalsozialismus. Mehr als 40.000 davon hat der Künstler Gunter Demnig mittlerweile in ganz Europa verlegt. Mit dieser App haben Sie schnell und einfach Zugriff auf Orte und Adressen der rund 5.000 Stolpersteine in Berlin.";
    [self.stolpersteineInfoButton setTitle:@"Stolpersteine auf Wikipedia" forState:UIControlStateNormal];
    [self.artistInfoButton setTitle:@"Gunter Demnigs Webseite" forState:UIControlStateNormal];
	
	// About
	self.aboutLabel.text = @"Gefällt Ihnen diese App? Über Ihre Bewertung oder eine Weiterempfehlung würden wir uns freuen.";
	[self.ratingButton setTitle:@"Im App Store bewerten" forState:UIControlStateNormal];
	[self.recommendButton setTitle:@"An Freunde weiterempfehlen" forState:UIControlStateNormal];
	
	// Sources
	self.sourceLabel.text = @"Wir bedanken uns bei den folgenden Organisationen, die uns die Daten für diese App zur Verfügung gestellt haben.";
	[self.kssButton setTitle:@"Koordinierungsstelle Stolpersteine Berlin" forState:UIControlStateNormal];
	[self.wikipediaButton setTitle:@"Wikipedia" forState:UIControlStateNormal];
	
	// Acknowledgements
	self.acknowledgementsLabel.text = @"Diese App ist quelloffen und jeder kann mitmachen. Beiträge von Claus Höfele, Hendrik Spree und Rachel Höfele";
	[self.contactButton setTitle:@"Schreiben Sie uns eine E-Mail" forState:UIControlStateNormal];
	[self.gitHubButton setTitle:@"Stolpersteine App auf GitHub" forState:UIControlStateNormal];
	
	// Legal
	self.legalLabel.text = @"Claus Höfele\nCalvinstr. 20b\n10557 Berlin";
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
        title = @"Über diese App";
    } else if (section == 2) {
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
