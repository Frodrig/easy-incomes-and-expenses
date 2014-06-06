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
#import "IAEHelpPasswordIndexViewController.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAESettingsViewControllerDefs.h"

#pragma mark - Enums

typedef NS_ENUM(NSUInteger, IAESettingsIndexOptionType) {
    IAESettingsIndexOptionConfigure,
    IAESettingsIndexOptionPassword,
    IAESettingsIndexOptionHelp,
    IAESettingsIndexOptionAbout,
};

#pragma mark - Constants

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";
static NSString * const kNotificationInitialMonthChanged = @"initialMonthChange";
static NSString * const kNotificationHelpOptionPressed = @"helpOptionPressed";
static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

#pragma mark - Interface

@interface IAEHelpIndexViewController ()

@property (nonatomic) BOOL dayModeWasActiveAtStart;
@property (nonatomic) MonthType monthInitialAtStart;
@property (nonatomic, strong) NSArray *optionsForLiteVersion;
@property (nonatomic, strong) NSArray *optionsForProVersion;

@end

@implementation IAEHelpIndexViewController

#pragma mark - Properties

- (NSArray *)optionsForLiteVersion
{
    if (!_optionsForLiteVersion) {
        _optionsForLiteVersion = @[@(IAESettingsIndexOptionConfigure), @(IAESettingsIndexOptionHelp), @(IAESettingsIndexOptionAbout)];
    }
    
    return _optionsForLiteVersion;
}

- (NSArray *)optionsForProVersion
{
    if (!_optionsForProVersion) {
        _optionsForProVersion = @[@(IAESettingsIndexOptionConfigure), @(IAESettingsIndexOptionPassword), @(IAESettingsIndexOptionHelp), @(IAESettingsIndexOptionAbout)];
    }
    
    return _optionsForProVersion;
}

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
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonPressed:)];
}

#pragma mark - Model

- (NSArray *)findOptionsForActualVersion
{
    return [[NSUserDefaults standardUserDefaults] isProVersionEnabled] ? self.optionsForProVersion : self.optionsForLiteVersion;
}

#pragma mark - IAEHelpIndexViewControllerDelegate

- (void)dismissAll
{
    [self dismissAllAndNotifyPressingHelpOption:NO];
}

- (void)dismissAllAndNotifyPressingHelpOption:(BOOL)notifyPressingHelpOption
{
    [self notifyGlobalValueChangesIfAppropiate];
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        if (notifyPressingHelpOption) {
            [self notifyHelpOptionPressed];
        }
    }];
}

#pragma mark - BarButtons

- (void)doneButtonPressed:(id)sender
{
    [self dismissAllAndNotifyPressingHelpOption:NO];
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

- (void)notifyHelpOptionPressed
{
    NSNotification *notification = [NSNotification notificationWithName:kNotificationHelpOptionPressed object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:notification];
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
    return [self findOptionsForActualVersion].count;
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
    IAESettingsIndexOptionType optionType = [self findOptionTypeFromIndexPath:indexPath];

    const NSUInteger indexSufix = optionType + 1;
    NSString *ltext = [NSString stringWithFormat:@"LTEXT_SETTINGSINDEX_%lu", (unsigned long)indexSufix];
    cell.textLabel.text = NSLocalizedString(ltext, @"");
    NSString *imageName = [NSString stringWithFormat:@"settingsindex_img_%lu", (unsigned long)indexSufix];
    cell.imageView.image = [UIImage imageNamed:imageName];
    cell.accessoryType = optionType == IAESettingsIndexOptionHelp ? UITableViewCellAccessoryNone : UITableViewCellAccessoryDisclosureIndicator;
}

- (BOOL)isIndexPathRelatedToHelpOption:(NSIndexPath *)indexPath
{
    IAESettingsIndexOptionType optionType = (IAESettingsIndexOptionType)[[[self findOptionsForActualVersion] objectAtIndex:indexPath.row] unsignedIntegerValue];
    return optionType == IAESettingsIndexOptionHelp;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self findOptionTypeFromIndexPath:indexPath] == IAESettingsIndexOptionHelp) {
        [self dismissAllAndNotifyPressingHelpOption:YES];
    } else {
        UIViewController *nextViewController = [self createNextViewControllerBasedInSelectRowAtIndexPath:indexPath];
        [self.navigationController pushViewController:nextViewController animated:YES];
    }
}

- (UIViewController *)createNextViewControllerBasedInSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *viewController = nil;
    IAESettingsIndexOptionType optionType = [self findOptionTypeFromIndexPath:indexPath];
    
    if (optionType == IAESettingsIndexOptionConfigure) {
        [Flurry logEvent:@"settingsindex_configure"];
        viewController = [[IAEHelpConfigureViewController alloc] initWithNibName:@"IAEHelpConfigureViewController" bundle:[NSBundle mainBundle]];
    } else if (optionType == IAESettingsIndexOptionPassword) {
        [Flurry logEvent:@"settingsindex_password"];
        viewController = [[IAEHelpPasswordIndexViewController alloc] initWithNibName:@"IAEHelpPasswordIndexViewController" bundle:[NSBundle mainBundle]];
    } else if (optionType == IAESettingsIndexOptionHelp) {
        [Flurry logEvent:@"settingsindex_help"];
        viewController = [[IAEHelpViewController alloc] initWithNibName:@"IAEHelpViewController" bundle:[NSBundle mainBundle]];
    } else if (optionType == IAESettingsIndexOptionAbout) {
        [Flurry logEvent:@"settingsindex_about"];
        viewController = [[IAEHelpAboutViewController alloc] initWithNibName:@"IAEHelpAboutViewController" bundle:[NSBundle mainBundle]];
    }

    [viewController performSelector:@selector(setDelegate:) withObject:self];
    
    return viewController;
}

- (IAESettingsIndexOptionType)findOptionTypeFromIndexPath:(NSIndexPath *)indexPath
{
    IAESettingsIndexOptionType optionType = (IAESettingsIndexOptionType)[[[self findOptionsForActualVersion] objectAtIndex:indexPath.row] unsignedIntegerValue];
    return optionType;
}

#pragma mark - MFMailComposeViewControllerDelegate

-(void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [controller dismissViewControllerAnimated:YES completion:nil];
    [self dismissAllAndNotifyPressingHelpOption:NO];
}


@end
