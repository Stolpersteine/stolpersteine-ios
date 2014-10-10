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
#import "ConfigurationService.h"

#import <MessageUI/MessageUI.h>

#define APP_STORE_ID @"640731757"
#define EMAIL_OPTION_U @"stolpersteine@option-u.com"

#define PADDING_LEFT 15
#define PADDING_RIGHT 20
#define PADDING_TOP 15
#define PADDING_BOTTOM 15
#define PADDING_SPACING 8

#define STOLPERSTEINE_SECTION 0
#define STOLPERSTEINE_PADDING (150 + PADDING_SPACING + PADDING_BOTTOM)

#define ABOUT_SECTION 1
#define ABOUT_PADDING (PADDING_TOP + PADDING_BOTTOM)

#define ACKNOWLEDGEMENTS_SECTION 2
#define SOURCES_PADDING (PADDING_TOP + PADDING_BOTTOM)
#define ACKNOWLEDGEMENTS_PADDING (PADDING_TOP + PADDING_BOTTOM)

#define LEGAL_SECTION 3
#define LEGAL_PADDING (PADDING_TOP + 88 + PADDING_SPACING + PADDING_BOTTOM)

@interface InfoViewController() <MFMailComposeViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *stolpersteineLabel;
@property (weak, nonatomic) IBOutlet UIButton *stolpersteineInfoButton;
@property (weak, nonatomic) IBOutlet UIButton *artistInfoButton;

@property (weak, nonatomic) IBOutlet UILabel *aboutLabel;
@property (weak, nonatomic) IBOutlet UIButton *ratingButton;
@property (weak, nonatomic) IBOutlet UIButton *recommendButton;

@property (weak, nonatomic) IBOutlet UILabel *sourcesLabel;
@property (weak, nonatomic) IBOutlet UIButton *berlinKSSButton;
@property (weak, nonatomic) IBOutlet UIButton *bochumAFGButton;
@property (weak, nonatomic) IBOutlet UIButton *berlinWikipediaButton;

@property (weak, nonatomic) IBOutlet UILabel *acknowledgementsLabel;
@property (weak, nonatomic) IBOutlet UIButton *contactButton;
@property (weak, nonatomic) IBOutlet UIButton *gitHubButton;

@property (weak, nonatomic) IBOutlet UILabel *legalLabel;

@end

@implementation InfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = NSLocalizedString(@"InfoViewController.title", nil);
    
	// Stolpersteine
    self.stolpersteineLabel.text = NSLocalizedString(@"InfoViewController.stolpersteineText", nil);
    [self.stolpersteineInfoButton setTitle:NSLocalizedString(@"InfoViewController.stolpersteineInfoTitle", nil) forState:UIControlStateNormal];
    [self.artistInfoButton setTitle:NSLocalizedString(@"InfoViewController.artistInfoTitle", nil) forState:UIControlStateNormal];
	
	// About
    NSString *formatString = NSLocalizedString(@"InfoViewController.aboutText", nil);
    NSString *appShortVersion = [ConfigurationService appShortVersion];
    NSString *appVersion = [ConfigurationService appVersion];
	self.aboutLabel.text = [NSString stringWithFormat:formatString, appShortVersion, appVersion];
	[self.ratingButton setTitle:NSLocalizedString(@"InfoViewController.ratingTitle", nil) forState:UIControlStateNormal];
	[self.recommendButton setTitle:NSLocalizedString(@"InfoViewController.recommendTitle", nil) forState:UIControlStateNormal];
	
    // Acknowledgements
	self.sourcesLabel.text = NSLocalizedString(@"InfoViewController.sourcesText", nil);
	[self.berlinKSSButton setTitle:NSLocalizedString(@"InfoViewController.berlinKSSTitle", nil) forState:UIControlStateNormal];
	[self.bochumAFGButton setTitle:NSLocalizedString(@"InfoViewController.bochumAFGTitle", nil) forState:UIControlStateNormal];
	[self.berlinWikipediaButton setTitle:NSLocalizedString(@"InfoViewController.berlinWikipediaTitle", nil) forState:UIControlStateNormal];
	self.acknowledgementsLabel.text = NSLocalizedString(@"InfoViewController.acknowledgementsText", nil);
	[self.contactButton setTitle:NSLocalizedString(@"InfoViewController.contactTitle", nil) forState:UIControlStateNormal];
	[self.gitHubButton setTitle:NSLocalizedString(@"InfoViewController.gitHubTitle", nil) forState:UIControlStateNormal];
	
	// Legal
	self.legalLabel.text = NSLocalizedString(@"InfoViewController.legalText", nil);
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
    } else if (indexPath.section == ACKNOWLEDGEMENTS_SECTION && indexPath.row == 0) {
        label = self.sourcesLabel;
        padding = SOURCES_PADDING;
    } else if (indexPath.section == ACKNOWLEDGEMENTS_SECTION && indexPath.row == 4) {
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
        title = NSLocalizedString(@"InfoViewController.stolpersteineSection", nil);
    } else if (section == ABOUT_SECTION) {
        title = NSLocalizedString(@"InfoViewController.aboutSection", nil);
    } else if (section == ACKNOWLEDGEMENTS_SECTION) {
        title = NSLocalizedString(@"InfoViewController.acknowledgementsSection", nil);
    } else if (section == LEGAL_SECTION) {
        title = NSLocalizedString(@"InfoViewController.legalSection", nil);
    } else {
        title = [super tableView:tableView titleForHeaderInSection:section];
    }
    
    return title;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    NSString *urlString, *diagnosticsLabel;
    if (indexPath.section == STOLPERSTEINE_SECTION) {
        if (indexPath.row == 1) {
            urlString = NSLocalizedString(@"InfoViewController.wikipediaURL", nil);
            diagnosticsLabel = @"wikipedia";
        } else if (indexPath.row == 2) {
            urlString = NSLocalizedString(@"InfoViewController.demnigURL", nil);
            diagnosticsLabel = @"demnig";
        }
    } else if (indexPath.section == ABOUT_SECTION) {
        if (indexPath.row == 1) {
            urlString = [NSString stringWithFormat:@"itms-apps://itunes.apple.com/app/id%@", APP_STORE_ID];
            diagnosticsLabel = @"appStore";
        } else if (indexPath.row == 2) {
            NSString *subject = NSLocalizedString(@"InfoViewController.recommendationSubject", nil);
            NSString *message = NSLocalizedString(@"InfoViewController.recommendationMessage", nil);
            [self sendMailWithRecipient:nil subject:subject message:message];
            diagnosticsLabel = @"recommendation";
        }
    } else if (indexPath.section == ACKNOWLEDGEMENTS_SECTION) {
        if (indexPath.row == 1) {
            urlString = NSLocalizedString(@"InfoViewController.berlinKSSURL", nil);
            diagnosticsLabel = @"kssBerlin";
        } else if (indexPath.row == 2) {
            urlString = NSLocalizedString(@"InfoViewController.bochumAFGURL", nil);
            diagnosticsLabel = @"wikipediaBerlin";
        } else if (indexPath.row == 3) {
            urlString = NSLocalizedString(@"InfoViewController.berlinWikipediaURL", nil);
            diagnosticsLabel = @"wikipediaBerlin";
        } else if (indexPath.row == 4) {
            NSString *subject = NSLocalizedString(@"InfoViewController.contactSubject", nil);
            NSString *version = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleVersion"];
            NSString *shortVersion = [[NSBundle.mainBundle infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            NSString *messageFormat = NSLocalizedString(@"InfoViewController.contactMessage", nil);
            NSString *message = [NSString stringWithFormat:messageFormat, shortVersion, version];
            [self sendMailWithRecipient:EMAIL_OPTION_U subject:subject message:message];
            diagnosticsLabel = @"contact";
        } else if (indexPath.row == 5) {
            urlString = NSLocalizedString(@"InfoViewController.gitHubURL", nil);
            diagnosticsLabel = @"gitHub";
        }
    }
    
    [AppDelegate.diagnosticsService trackEvent:DiagnosticsServiceEventInfoItemTapped withClass:self.class label:diagnosticsLabel];
    
    NSURL *url = [NSURL URLWithString:urlString];
    if ([UIApplication.sharedApplication canOpenURL:url]) {
        [UIApplication.sharedApplication openURL:url];
    }
}

- (void)sendMailWithRecipient:(NSString *)recipient subject:(NSString *)subject message:(NSString *)message
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *composeViewController = [[MFMailComposeViewController alloc] init];
        composeViewController.mailComposeDelegate = self;
        
        if (recipient) {
            composeViewController.toRecipients = @[recipient];
        }
        composeViewController.subject = subject;
        [composeViewController setMessageBody:message isHTML:NO];
        
        [self presentViewController:composeViewController animated:YES completion:NULL];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)close:(UIBarButtonItem *)sender
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
