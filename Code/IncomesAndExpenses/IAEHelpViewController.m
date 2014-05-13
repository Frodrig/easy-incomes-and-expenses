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
#import "IAEHelpSelectorTableViewCell.h"
#import "IAEHelpSelectorTableViewCellDelegate.h"

#pragma mark - Constants

static const NSUInteger kNumberOfSections = 2;
static const NSUInteger kHelpSelectorSectionIndex = 0;
static const NSUInteger kHelpContentSectionIndex = 1;
static NSString * const kHelpSelectorCellIdentifier = @"HelpSelectorCell";
static NSString * const kHelpContentCellIdentifier = @"HelpContentCell";
static const CGFloat kHelpSelectorSectionHeight = 44;
static const CGFloat kHelpContentSectionHeight = 64;

#pragma mark - Interface

@interface IAEHelpViewController ()<IAEHelpSelectorTableViewCellDelegate>

@property (nonatomic) IAEHelpThemeType actualHelpTheme;

@end

#pragma mark - Implementation

@implementation IAEHelpViewController

#pragma mark - Constantes

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _actualHelpTheme = HelpThemeAllVersion;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationController];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"IAEHelpSelectorTableViewCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:kHelpSelectorCellIdentifier];
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
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger retNumberOfRows = 1;

    if (section == kHelpContentSectionIndex) {
        retNumberOfRows = [self isActualHelpThemeAllVersion] ? [IAEHelpBook sharedHelpBook].allVersionThemes.count : [IAEHelpBook sharedHelpBook].proVersionThemes.count;
    }
    
    return retNumberOfRows;
}

- (BOOL)isActualHelpThemeAllVersion
{
    return self.actualHelpTheme == HelpThemeAllVersion;
}

- (BOOL)isActualHelpThemeProVersion
{
    return self.actualHelpTheme == HelpThemeProVersion;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if ([self isHelpSelectorSectionOfIndexPath:indexPath]) {
        IAEHelpSelectorTableViewCell *helpSelectorTableViewCell = [tableView dequeueReusableCellWithIdentifier:kHelpSelectorCellIdentifier forIndexPath:indexPath];
        helpSelectorTableViewCell.delegate = self;
        cell = helpSelectorTableViewCell;
    } else if ([self isHelpContentSectionOfIndexPath:indexPath]) {
        cell = [self newHelpContentCellForTableView:tableView forRowAtIndexPath:indexPath];
        [self configureHelpContentCell:cell ofTableView:tableView forRowAtIndexPath:indexPath];
    }
    
    return cell;
}

- (BOOL)isHelpSelectorSectionOfIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kHelpSelectorSectionIndex;
}

- (BOOL)isHelpContentSectionOfIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kHelpContentSectionIndex;
}

- (UITableViewCell *)newHelpContentCellForTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kHelpContentCellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kHelpContentCellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
    }
    
    return cell;
}

- (void)configureHelpContentCell:(UITableViewCell *)cell ofTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAEHelpTheme *helpTheme = [[self findContainerThemesForActualHelpTheme] objectAtIndex:indexPath.row];
    cell.textLabel.text = helpTheme.title;
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

- (NSArray *)findContainerThemesForActualHelpTheme
{
    return [self isActualHelpThemeAllVersion] ? [IAEHelpBook sharedHelpBook].allVersionThemes : [IAEHelpBook sharedHelpBook].proVersionThemes;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isHelpContentSectionOfIndexPath:indexPath]) {
        [self launchThemeViewControllerWithThemeIndex:indexPath.row];
    }
}

- (void)launchThemeViewControllerWithThemeIndex:(NSUInteger)themeIndex
{
    IAEHelpTheme *theme = [[self findContainerThemesForActualHelpTheme] objectAtIndex:themeIndex];
    IAEHelpThemeViewController *themeViewController = [[IAEHelpThemeViewController alloc] initWithHelpTheme:theme];
    themeViewController.delegate = self.delegate;
    [self.navigationController pushViewController:themeViewController animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat retHeightRow = kHelpContentSectionHeight;
    if (indexPath.section == kHelpSelectorSectionIndex) {
        retHeightRow = kHelpSelectorSectionHeight;
    }
    
    return retHeightRow;
}

#pragma mark - IAEHelpSelectorTableViewCellDelegate

- (void)helpSelectorTableViewCell:(IAEHelpSelectorTableViewCell *)cell didChangeSelectorIndexToHelpThemeType:(IAEHelpThemeType)helpThemeType
{
    self.actualHelpTheme = helpThemeType;
    [self.tableView reloadSections:[[NSIndexSet alloc] initWithIndex:1] withRowAnimation:UITableViewRowAnimationAutomatic];
}


@end

