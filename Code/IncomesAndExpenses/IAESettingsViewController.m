//
//  IAESettingsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 27/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESettingsViewController.h"
#import "IAEConstants.h"
#import "IAEAboutViewController.h"

@interface IAESettingsViewController ()

@end

@implementation IAESettingsViewController

@synthesize popoverFatherController = popoverFatherController_;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    self.navigationItem.title = NSLocalizedString(@"Info", @"Info titulo");
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [IAEConstants sectionsSettingsBackgroundColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.contentSizeForViewInPopover = CGSizeMake(300.0, 155.0);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [IAEConstants sectionsTablesBackgroundColor];
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    /*
    if (indexPath.row == 0) {
        cell.textLabel.text = @"Help";
        cell.imageView.image = [UIImage imageNamed:@"451-help-symbol2.png"];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = @"Send Feedback";
        cell.imageView.image = [UIImage imageNamed:@"216-compose.png"];        
    } else if (indexPath.row == 2) {
        cell.textLabel.text = @"About";
        cell.imageView.image = [UIImage imageNamed:@"452-information-symbol2.png"];
    }
    */
    if (indexPath.row == 0) {
        cell.textLabel.text = NSLocalizedString(@"Send Feedback", @"Opcion para mandar feedback");
        cell.imageView.image = [UIImage imageNamed:@"287-at.png.png"];
    } else if (indexPath.row == 1) {
        cell.textLabel.text = NSLocalizedString(@"About", @"Seccion acerca de");
        cell.imageView.image = [UIImage imageNamed:@"452-information-symbol2.png"];
    }
    return cell;
}
/*
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Info";
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return @"(C) 2013 Fernando Rodríguez";
}
*/
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {
        MFMailComposeViewController *appEmailViewController = [[MFMailComposeViewController alloc] init];
        appEmailViewController.mailComposeDelegate = self;
        NSString *emailSubject = NSLocalizedString(@"LTEXT_EMAIL_SUBJECT", @"Email feedback");
        emailSubject = [emailSubject stringByAppendingString:NSLocalizedString(@"LTEXT_VERSION", @"")];
        [appEmailViewController setSubject:NSLocalizedString(emailSubject, @"")];
        [appEmailViewController setToRecipients:[NSArray arrayWithObject:NSLocalizedString(@"LTEXT_EMAIL", @"")]];
        [self presentViewController:appEmailViewController animated:YES completion:nil];
    } else if (indexPath.row == 1) {
        IAEAboutViewController *aboutViewController = [[IAEAboutViewController alloc] initWithNibName:nil bundle:nil];
        aboutViewController.popoverFatherController = self.popoverFatherController;
        [self.navigationController pushViewController:aboutViewController animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66.0;
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    [self.popoverFatherController dismissPopoverAnimated:YES];
    [self.popoverFatherController.delegate popoverControllerDidDismissPopover:self.popoverFatherController];
}

@end
