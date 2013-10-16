//
//  IAEHelpIndexViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpIndexViewController.h"
#import "IAEHelpConfigureViewController.h"
#import "IAEHelpAboutViewController.h"

@interface IAEHelpIndexViewController ()

@property (nonatomic) BOOL dayModeWasActiveAtStart;

@end

@implementation IAEHelpIndexViewController

#pragma mark - Constants

static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";

const NSInteger kIndexSize = 3;

const NSUInteger kRowOfConfigureIndex = 0;
const NSUInteger kRowOfHelpIndex = 1;
const NSUInteger kRowOfAboutIndex = 2;

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
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configureNavigationController];
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_HELPINDEX_TITLE", @"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                          target:self
                                                                                          action:@selector(doneButtonPressed:)];
}

#pragma mark - BarButtons

- (void)doneButtonPressed:(id)sender
{
    [self notifyGlobalValueChangesIfAppropiate];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)notifyGlobalValueChangesIfAppropiate
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
    [self configureCell:cell forIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)newCellForTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell forIndexPath:(NSIndexPath *)indexPath
{
    const NSUInteger indexSufix = indexPath.row + 1;
    NSString *ltext = [NSString stringWithFormat:@"LTEXT_HELPINDEX_%d", indexSufix];
    cell.textLabel.text = NSLocalizedString(ltext, @"");
    NSString *imageName = [NSString stringWithFormat:@"helpindex_%d", indexSufix];
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
        viewController = [[IAEHelpConfigureViewController alloc] initWithNibName:@"IAEHelpConfigureViewController" bundle:[NSBundle mainBundle]];
    } else if (indexPath.row == kRowOfAboutIndex) {
        viewController = [[IAEHelpAboutViewController alloc] initWithNibName:@"IAEHelpAboutViewController" bundle:[NSBundle mainBundle]];
    }
    
    return viewController;
}

@end
