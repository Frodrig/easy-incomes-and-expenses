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
#import "NSUserDefaults+EasyIncAndExp.h"
#import "KeychainItemWrapper.h"

@interface IAEHelpPasswordIndexViewController ()

@end

@implementation IAEHelpPasswordIndexViewController

#pragma mark - Constants

static const NSUInteger kActivateDeactivatePasswordIndex = 0;
static const NSUInteger kChangePasswordIndex = 1;

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
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_7", @"");
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
    return 2;
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
    } else if (indexPath.row == kChangePasswordIndex) {
        cell.textLabel.text = NSLocalizedString(@"LTEXT_PASSWORDINDEX_CHANGE", @"");
        cell.userInteractionEnabled = passwordActivated;
        cell.textLabel.enabled = passwordActivated;
        cell.detailTextLabel.enabled = passwordActivated;
    }
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (BOOL)isPasswordActivated
{
    const BOOL isPasswordActivated = [[KeychainItemWrapper defaultKeychain] isPasswordActivated];
    
    return isPasswordActivated;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
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
