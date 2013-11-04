//
//  IAEExportStepTwoViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportChooseHowAndWhatViewController.h"

@interface IAEExportChooseHowAndWhatViewController ()

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPathInHowSection;

@end

@implementation IAEExportChooseHowAndWhatViewController

#pragma mark - Constants

static const NSUInteger kHowSection = 0;
static const NSUInteger kWhatSection = 1;
static const NSUInteger kNumberOfRowsInHowSection = 3;
static const NSUInteger kNumberOfRowsInWhatSection = 4;

static const NSUInteger kHowOptionSelectedGlobalResumeIndex = 0;
static const NSUInteger kHowOptionSelectedMonthByMonthIndex = 1;
static const NSUInteger kHowOptionSelectedMonthByMonthAndGlobalResumeIndex = 2;

static NSString * const kHowOptionSelectedGlobalResumeUserInfoValue = @"globalResume";
static NSString * const kHowOptionSelectedMonthByMonthUserInfoValue = @"monthByMonth";
static NSString * const kHowOptionSelectedMonthByMonthAndGlobalResumeUserInfoValue = @"globalResumeAndMonthByMonth";

static const NSUInteger kWhatOptionSelectedTotalsIndex = 0;
static const NSUInteger kWhatOptionSelectedCategoryIncomesIndex = 1;
static const NSUInteger kWhatOptionSelectedCategoryExpensesIndex = 2;
static const NSUInteger kWhatOptionSelectedConceptsIndex = 3;

static NSString * const kWhatOptionSelectedTotalsInfoValue = @"totals";
static NSString * const kWhatOptionSelectedCategoryIncomesInfoValue = @"categoryIncomes";
static NSString * const kWhatOptionSelectedCategoryExpensesInfoValue = @"categoryExpenses";
static NSString * const kWhatOptionSelectedConceptsInfoValue = @"concepts";

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 24;

#pragma mark - Properties

#pragma mark - Init

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _selectedCellIndexPathInHowSection = nil;
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
    self.title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEHOWANDWHAT_TITLE", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_EXPORTCHOOSEHOWANDWHAT_NEXTBUTTONTITLE", @"")
                                                                              style:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(readyButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)readyButtonPressed:(id)sender
{
    NSLog(@"%@", self.userConfiguration);
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    if (section == kHowSection) {
        numberOfRows = kNumberOfRowsInHowSection;
    } else if (section == kWhatSection) {
        numberOfRows = kNumberOfRowsInWhatSection;
    }
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    NSString *cellText = [NSString stringWithFormat:@"LTEXT_EXPORTCHOOSEHOWANDWHAT_SECTION_%d_OPTION_%d", indexPath.section + 1, indexPath.row + 1];
    cell.textLabel.text = NSLocalizedString(cellText, @"");
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    if (section == kHowSection) {
        title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEHOWANDWHAT_SECTION_1", @"");
    } else if (section == kWhatSection) {
        title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEHOWANDWHAT_SECTION_2", @"");
    }
    
    return title;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == kHowSection) {
        UITableViewCell *oldSelectedCell = [tableView cellForRowAtIndexPath:self.selectedCellIndexPathInHowSection];
        oldSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        UITableViewCell *newSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        newSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        self.selectedCellIndexPathInHowSection = indexPath;
        
        [self updateUserConfigurationWithHowSection];
    } else if (indexPath.section == kWhatSection) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
        [self updateUserConfigurationWithWhatSection];
    }
    
    [self updateReadyButton];
}

- (void)updateUserConfigurationWithHowSection
{
    NSArray *optionIndexPathInHowSection = [self indexPathOfOptionSelectedInSection:kHowSection];
    NSAssert(optionIndexPathInHowSection.count == 0 || optionIndexPathInHowSection.count == 1, @"");
    if (optionIndexPathInHowSection.count == 1) {
        NSIndexPath *howOptionSelected = optionIndexPathInHowSection[0];
        NSString *howOptionUserInfoValue = [self convertHowOptionSelectedToUserInfoValue:howOptionSelected.row];
        self.userConfiguration[@"how_option"] = howOptionUserInfoValue;
    }
}

- (void)updateUserConfigurationWithWhatSection
{
    NSMutableSet *whatUserInfoValues = [NSMutableSet set];
    NSArray *optionsIndexPathInWhatSection =  [self indexPathOfOptionSelectedInSection:kWhatSection];
    for (NSIndexPath *indexPath in optionsIndexPathInWhatSection) {
        NSString *whatUserInfoValue = [self convertWhatOptionSelectedToUserInfoValue:indexPath.row];
        [whatUserInfoValues addObject:whatUserInfoValue];
    }
    
    self.userConfiguration[@"what_options"] = [NSSet setWithSet:whatUserInfoValues];
}

- (void)updateReadyButton
{
    NSArray *optionsSelectedInHowSection = [self indexPathOfOptionSelectedInSection:kHowSection];
    NSArray *optionsSelectedInWhatSection = [self indexPathOfOptionSelectedInSection:kWhatSection];
    
    const BOOL readyButtonEnabled = optionsSelectedInHowSection.count == 1 && optionsSelectedInWhatSection.count > 0;
    self.navigationItem.rightBarButtonItem.enabled = readyButtonEnabled;
}

- (NSString *)convertHowOptionSelectedToUserInfoValue:(NSUInteger)howOptionSelected
{
    NSString *howOptionUserInfoValue = nil;
    
    if (howOptionSelected == kHowOptionSelectedGlobalResumeIndex) {
        howOptionUserInfoValue = kHowOptionSelectedGlobalResumeUserInfoValue;
    } else if (howOptionSelected == kHowOptionSelectedMonthByMonthIndex) {
        howOptionUserInfoValue = kHowOptionSelectedMonthByMonthUserInfoValue;
    } else if (howOptionSelected == kHowOptionSelectedMonthByMonthAndGlobalResumeIndex) {
        howOptionUserInfoValue = kHowOptionSelectedMonthByMonthAndGlobalResumeUserInfoValue;
    }
    
    return howOptionUserInfoValue;
}

- (NSString *)convertWhatOptionSelectedToUserInfoValue:(NSUInteger)whatOptionSelected
{
    NSString *whatOptionUserInfoValue = nil;
    
    if (whatOptionSelected == kWhatOptionSelectedTotalsIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedTotalsInfoValue;
    } else if (whatOptionSelected == kWhatOptionSelectedCategoryIncomesIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedCategoryIncomesInfoValue;
    } else if (whatOptionSelected == kWhatOptionSelectedCategoryExpensesIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedCategoryExpensesInfoValue;
    } else if (whatOptionSelected == kWhatOptionSelectedConceptsIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedConceptsInfoValue;
    }

    return whatOptionUserInfoValue;
}

- (NSArray *)indexPathOfOptionSelectedInSection:(NSUInteger)section
{
    NSMutableArray *options = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cell];
        if (indexPathOfCell.section == section) {
            if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
                [options addObject:indexPathOfCell];
            }
        }
    }
    
    NSArray *retOptions = [NSArray arrayWithArray:options];
    return retOptions;
}

@end
