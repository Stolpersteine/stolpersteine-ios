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

#define PADDING_LEFT 15
#define PADDING_RIGHT 20
#define PADDING_TOP 15
#define PADDING_BOTTOM 15
#define PADDING_SPACING 8

#define STOLPERSTEINE_SECTION 0
#define STOLPERSTEINE_PADDING (150 + PADDING_SPACING + PADDING_BOTTOM)

#define ABOUT_SECTION 1
#define ABOUT_PADDING (PADDING_TOP + PADDING_BOTTOM)
#define SOURCES_PADDING (PADDING_TOP + PADDING_BOTTOM)
#define ACKNOWLEDGEMENTS_PADDING (PADDING_TOP + PADDING_BOTTOM)

#define LEGAL_SECTION 2
#define LEGAL_PADDING (PADDING_TOP + 88 + PADDING_SPACING + PADDING_BOTTOM)

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"InfoViewController.title", nil);
    
	// Stolpersteine
    self.stolpersteineLabel.text = @"Stolpersteine sind kleine Gedenktafeln im Straßenpflaster zur Erinnerung an die Opfer des Nationalsozialismus. Mehr als 40.000 davon hat der Künstler Gunter Demnig mittlerweile in ganz Europa verlegt. Mit dieser App haben Sie schnell und einfach Zugriff auf Ortsdaten und Adressen der rund 5.000 Stolpersteine in Berlin.";
    [self.stolpersteineInfoButton setTitle:@"Stolpersteine auf Wikipedia" forState:UIControlStateNormal];
    [self.artistInfoButton setTitle:@"Gunter Demnigs Webseite" forState:UIControlStateNormal];
	
	// About
	self.aboutLabel.text = @"Gefällt Ihnen diese App? Über Ihre Bewertung oder eine Weiterempfehlung würden wir uns freuen.";
	[self.ratingButton setTitle:@"Im App Store bewerten" forState:UIControlStateNormal];
	[self.recommendButton setTitle:@"An Freunde weiterempfehlen" forState:UIControlStateNormal];
	
	self.sourceLabel.text = @"Wir bedanken uns bei den folgenden Organisationen, die uns die Daten für diese App zur Verfügung gestellt haben:";
	[self.kssButton setTitle:@"Koordinierungsstelle Stolpersteine Berlin" forState:UIControlStateNormal];
	[self.wikipediaButton setTitle:@"Wikipedia" forState:UIControlStateNormal];
	
	self.acknowledgementsLabel.text = @"Diese App ist open source, damit jeder mitmachen kann. Beiträge von Claus Höfele, Hendrik Spree und Rachel Höfele";
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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    // To make sure table cells have correct height
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat padding;
    UILabel *label;
    if (indexPath.section == STOLPERSTEINE_SECTION && indexPath.row == 0) {
        label = self.stolpersteineLabel;
        padding = STOLPERSTEINE_PADDING;
    } else if (indexPath.section == ABOUT_SECTION && indexPath.row == 0) {
        label = self.aboutLabel;
        padding = ABOUT_PADDING;
    } else if (indexPath.section == ABOUT_SECTION && indexPath.row == 3) {
        label = self.sourceLabel;
        padding = SOURCES_PADDING;
    } else if (indexPath.section == ABOUT_SECTION && indexPath.row == 6) {
        label = self.acknowledgementsLabel;
        padding = ACKNOWLEDGEMENTS_PADDING;
    } else if (indexPath.section == LEGAL_SECTION && indexPath.row == 0) {
        label = self.legalLabel;
        padding = LEGAL_PADDING;
    }

    CGFloat height;
    if (label) {
        NSDictionary *attributes = @{
            NSFontAttributeName : [UIFont systemFontOfSize:15]
        };
        CGFloat width = self.tableView.frame.size.width - PADDING_LEFT - PADDING_RIGHT;
        label.preferredMaxLayoutWidth = width;
        CGRect boundingRect = [label.text boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:attributes context:nil];
        height = ceil(boundingRect.size.height) + padding;
    } else {
        height = [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    return height;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title;
    if (section == STOLPERSTEINE_SECTION) {
        title = @"Stolpersteine";
    } else if (section == ABOUT_SECTION) {
        title = @"Über diese App";
    } else if (section == LEGAL_SECTION) {
        title = @"Impressum";
    } else {
        title = [super tableView:tableView titleForHeaderInSection:section];
    }
    
    return title;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == STOLPERSTEINE_SECTION) {
        if (indexPath.row == 0) {
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == STOLPERSTEINE_SECTION) {
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
