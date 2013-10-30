//
//  IAEHelpIndexViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpIndexViewController.h"
#import "Flurry.h"
#import "IAEHelpConfigureViewController.h"
#import "IAEHelpAboutViewController.h"
#import "IAEHelpViewController.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEHelpIndexViewController ()

@property (nonatomic) BOOL dayModeWasActiveAtStart;
@property (nonatomic) MonthType monthInitialAtStart;

@end

@implementation IAEHelpIndexViewController

#pragma mark - Constants

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 24;

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";
static NSString * const kNotificationInitialMonthChanged = @"initialMonthChange";

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

static const NSInteger kIndexSize = 3;

static const NSUInteger kRowOfConfigureIndex = 0;
static const NSUInteger kRowOfHelpIndex = 1;
static const NSUInteger kRowOfAboutIndex = 2;

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        [self prepareGlobalSettingsInformation];
    }
    return self;
}

- (void)prepareGlobalSettingsInformation
{
    _dayModeWasActiveAtStart = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
    _monthInitialAtStart = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavigationController];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_SETTINGSINDEX_TITLE", @"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonPressed:)];
}

#pragma mark - IAEHelpIndexViewControllerDelegate

- (void)dismissAll
{
    [self notifyGlobalValueChangesIfAppropiate];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - BarButtons

- (void)doneButtonPressed:(id)sender
{
    [self dismissAll];
}

- (void)notifyGlobalValueChangesIfAppropiate
{
    [self notifyDayModeActiveIfAppropiate];
    [self notifyNewInitialMonthIfAppropiate];
}

- (void)notifyDayModeActiveIfAppropiate
{
    const BOOL actualDayModeActive = [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
    if (actualDayModeActive != self.dayModeWasActiveAtStart) {
        [self notifyDayModeChanged:actualDayModeActive];
    }
}

- (void)notifyDayModeChanged:(BOOL)dayModeOn
{
    NSString *notificationName = dayModeOn ? kNotificationDayModeOnName : kNotificationDayModeOffName;
    NSNotification *notification = [NSNotification notificationWithName:notificationName object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)notifyNewInitialMonthIfAppropiate
{
    MonthType actualInitialMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
    if (actualInitialMonth != self.monthInitialAtStart) {
        NSNotification *notification = [NSNotification notificationWithName:kNotificationInitialMonthChanged
                                                                     object:nil
                                                                   userInfo:@{@"newInitialMonth": @(actualInitialMonth)}];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kIndexSize;
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
    const NSUInteger indexSufix = indexPath.row + 1;
    NSString *ltext = [NSString stringWithFormat:@"LTEXT_SETTINGSINDEX_%d", indexSufix];
    cell.textLabel.text = NSLocalizedString(ltext, @"");
    NSString *imageName = [NSString stringWithFormat:@"settingsindex_%d", indexSufix];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *nextViewController = [self createNextViewControllerBasedInSelectRowAtIndexPath:indexPath];
    [self.navigationController pushViewController:nextViewController animated:YES];
}

- (UIViewController *)createNextViewControllerBasedInSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    
    if (indexPath.row == kRowOfConfigureIndex) {
        [Flurry logEvent:@"settingsindex_configure"];
        viewController = [[IAEHelpConfigureViewController alloc] initWithNibName:@"IAEHelpConfigureViewController" bundle:[NSBundle mainBundle]];
    } else if (indexPath.row == kRowOfHelpIndex) {
        [Flurry logEvent:@"settingsindex_help"];
        viewController = [[IAEHelpViewController alloc] initWithNibName:@"IAEHelpViewController" bundle:[NSBundle mainBundle]];
    } else if (indexPath.row == kRowOfAboutIndex) {
        [Flurry logEvent:@"settingsindex_about"];
        viewController = [[IAEHelpAboutViewController alloc] initWithNibName:@"IAEHelpAboutViewController" bundle:[NSBundle mainBundle]];
    }

    [viewController performSelector:@selector(setDelegate:) withObject:self];
    
    return viewController;
}

@end
