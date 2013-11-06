//
//  IAEChooseMonthsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportChooseMonthsViewController.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEExportChooseWhatViewController.h"
#import "IAEOpenYear.h"
#import "IAEDateHelper.h"
#import "IAEMonth.h"

@interface IAEExportChooseMonthsViewController ()

@end

@implementation IAEExportChooseMonthsViewController


#pragma mark - Constants

static const NSUInteger kNumberOfMonth = 12;

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 24;

static NSString * const kSelectedMonths = @"month_selected";

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
    self.title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEMONTHS_TITLE", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_EXPORTCHOOSEMONTHS_NEXTBUTTONTITLE", @"")
                                                                              style:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(nextStepButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - BarButtonsActions

- (void)nextStepButtonPressed:(id)sender
{
    [self lauchChooseHowAndWhatViewController];
}

- (void)lauchChooseHowAndWhatViewController
{
    IAEExportChooseWhatViewController *whatViewController = [[IAEExportChooseWhatViewController alloc] initWithNibName:nil bundle:nil];
    whatViewController.userConfiguration = self.userConfiguration;
    whatViewController.query = self.query;
    
    [self.navigationController pushViewController:whatViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfMonth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self createCellInTableView:tableView forRowAtIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)createCellInTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    IAEOpenYear *openYear = [self.query findOpenYear];
    IAEMonth *month = openYear.months[indexPath.row];
    cell.textLabel.text = [IAEDateHelper findMonthNameStringWithMonthIndex:month.month inShortForm:NO];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    IAEOpenYear *openYear = [self.query findOpenYear];
    NSString *title = [IAEDateHelper createYearIdentificationTagFromYearDate:openYear.yearDate withShortForm:YES];
    
    return title;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
    
    [self updateUserConfiguration];
    [self updateNextStepButton];
}

- (void)updateUserConfiguration
{
    NSMutableArray *selectedMonths = [NSMutableArray array];
    
    IAEOpenYear *openYear = [self.query findOpenYear];
    NSArray *visibleCells = self.tableView.visibleCells;
    for (UITableViewCell * cell in visibleCells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cell];
            IAEMonth *month = [openYear.months objectAtIndex:indexPathOfCell.row];
            [selectedMonths addObject:month];
        }
    }
    
    self.userConfiguration[kSelectedMonths] = [NSArray arrayWithArray:selectedMonths];
}

- (void)updateNextStepButton
{
    self.navigationItem.rightBarButtonItem.enabled = [self.userConfiguration[kSelectedMonths] count] > 0;
}


@end
