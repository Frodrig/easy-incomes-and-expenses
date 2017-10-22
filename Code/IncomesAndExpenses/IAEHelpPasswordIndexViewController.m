//
//  IAEHelpPasswordIndexViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpPasswordIndexViewController.h"
#import "IAESettingsViewControllerDefs.h"
#import "IAEPasswordPanelViewController.h"
#import "IAEPasswordRecoveryEmailPanelViewController.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "KeychainItemWrapper.h"

@interface IAEHelpPasswordIndexViewController ()

@end

@implementation IAEHelpPasswordIndexViewController

#pragma mark - Constants

static const NSUInteger kActivateDeactivatePasswordIndex = 0;
static const NSUInteger kChangePasswordIndex = 1;
static const NSUInteger kVinculePasswordRecoverEmailIndex = 2;
static const NSUInteger kNumberOfOptionsAvailable = 3;

#pragma mark - Init

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
    
    [self configureNavigationController];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_2", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfOptionsAvailable;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self newCellForTableView:tableView atIndexPath:indexPath];
    [self configureCell:cell ofTableView:tableView forIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)newCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
    }
 
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell ofTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    const BOOL passwordActivated = [self isPasswordActivated];
    if (indexPath.row == kActivateDeactivatePasswordIndex) {
        cell.textLabel.text =  passwordActivated ? NSLocalizedString(@"LTEXT_PASSWORDINDEX_DEACTIVATE", @"") : NSLocalizedString(@"LTEXT_PASSWORDINDEX_ACTIVATE", @"");
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
    } else if (indexPath.row == kChangePasswordIndex) {
        cell.textLabel.text = NSLocalizedString(@"LTEXT_PASSWORDINDEX_CHANGE", @"");
        cell.userInteractionEnabled = passwordActivated;
        cell.textLabel.enabled = passwordActivated;
        cell.detailTextLabel.enabled = passwordActivated;
    } else if (indexPath.row == kVinculePasswordRecoverEmailIndex) {
        cell.textLabel.text = NSLocalizedString(@"LTEXT_PASSWORDINDEX_VINCULEEMAIL", @"");
        cell.userInteractionEnabled = YES;
        cell.textLabel.enabled = YES;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (BOOL)isPasswordActivated
{
    const BOOL isPasswordActivated = [[KeychainItemWrapper defaultKeychain] isPasswordActivated];
    
    return isPasswordActivated;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isIndexPathForPasswordPanelViewController:indexPath]) {
        [self launchPasswordPanelViewControllerWithAppropiateModeForIndexPath:indexPath];
    } else if ([self isIndexPathForVinculePasswordRecoveryEmail:indexPath]) {
        [self executeLogicForVinculePasswordRecoveryEmailSectionForIndexPath:indexPath];
    }
}

- (BOOL)isIndexPathForVinculePasswordRecoveryEmail:(NSIndexPath *)indexPath
{
    return indexPath.row == kVinculePasswordRecoverEmailIndex;
}

- (void)executeLogicForVinculePasswordRecoveryEmailSectionForIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[NSIndexPath indexPathForRow:kVinculePasswordRecoverEmailIndex inSection:0] animated:YES];

    if ([MFMailComposeViewController canSendMail]) {
        [self launchEmailRecoveryPanelViewController];
    } else {
        [self launchAlertViewAboutCantVinculeEmailRecovery];
    }
}

-(void)launchEmailRecoveryPanelViewController
{
    [self.navigationController presentViewController:[[IAEPasswordRecoveryEmailPanelViewController alloc] initWithNibName:nil bundle:nil] animated:YES completion:^{
        
    }];
}

- (void)launchAlertViewAboutCantVinculeEmailRecovery
{
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANEL_CANTVINCULEMAIL_ALERTVIEW_TITLE", @"")
                                message:NSLocalizedString(@"LTEXT_PASSWORDPANEL_CANTVINCULEMAIL_ALERTVIEW_MESSAGE", @"")
                                preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* okButton = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"LTEXT_PASSWORDPANEL_CANTVINCULEMAIL_ALERTVIEW_OK", @"")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                               }];
    
    [alert addAction:okButton];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (BOOL)isIndexPathForPasswordPanelViewController:(NSIndexPath *)indexPath
{
    return indexPath.row == kActivateDeactivatePasswordIndex || indexPath.row == kChangePasswordIndex;
}

- (void)launchPasswordPanelViewControllerWithAppropiateModeForIndexPath:(NSIndexPath *)indexPath
{
    ModeType mode = [self findModeTypeBasedInSelectedRowAtIndexPath:indexPath];
    IAEPasswordPanelViewController *passwordPanelViewController = [[IAEPasswordPanelViewController alloc] initWithMode:mode];
    passwordPanelViewController.delegate = self.delegate;
    
    [self.navigationController pushViewController:passwordPanelViewController animated:YES];
}

- (ModeType)findModeTypeBasedInSelectedRowAtIndexPath:(NSIndexPath *)indexPath
{
    ModeType retMode = MT_Change;
    if (indexPath.row == kActivateDeactivatePasswordIndex) {
        retMode = [self isPasswordActivated] ? MT_Deactivate : MT_Activate;
    }
    
    return retMode;
}


@end
