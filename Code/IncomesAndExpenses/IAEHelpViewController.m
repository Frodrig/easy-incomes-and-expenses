//
//  IAEHelpViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 16/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpViewController.h"
#import "IAEHelpBook.h"
#import "IAEHelpTheme.h"
#import "IAEHelpThemeViewController.h"
#import "IAEHelpIndexViewControllerDelegate.h"
#import "IAESettingsViewControllerDefs.h"

@interface IAEHelpViewController ()

@end

@implementation IAEHelpViewController

#pragma mark - Constantes

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
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_3", @"");
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
     */
}

#pragma mark - Navigation Bar

- (void)doneButtonPressed:(UIBarButtonItem *)button
{
    [self.delegate dismissAll];
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
    return [IAEHelpBook sharedHelpBook].themes.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self newCellForTableView:tableView forRowAtIndexPath:indexPath];
    [self configureCell:cell ofTableView:tableView forRowAtIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)newCellForTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell ofTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAEHelpTheme *helpTheme = [[IAEHelpBook sharedHelpBook].themes objectAtIndex:indexPath.row];
    cell.textLabel.text = helpTheme.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self launchThemeViewControllerWithThemeIndex:indexPath.row];
}

- (void)launchThemeViewControllerWithThemeIndex:(NSUInteger)themeIndex
{
    IAEHelpTheme *theme = [[IAEHelpBook sharedHelpBook].themes objectAtIndex:themeIndex];
    IAEHelpThemeViewController *themeViewController = [[IAEHelpThemeViewController alloc] initWithHelpTheme:theme];
    themeViewController.delegate = self.delegate;
    [self.navigationController pushViewController:themeViewController animated:YES];
}

@end
