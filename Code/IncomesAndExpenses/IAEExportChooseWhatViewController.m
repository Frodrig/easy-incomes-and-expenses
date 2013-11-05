//
//  IAEExportStepTwoViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportChooseWhatViewController.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEExporter.h"
#import "IAEOpenYear.h"

@interface IAEExportChooseWhatViewController ()

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPathInHowSection;

@end

@implementation IAEExportChooseWhatViewController

#pragma mark - Constants

static const NSUInteger kNumberOfRowsInWhatSection = 3;

static const NSUInteger kWhatOptionSelectedGlobalsReportIndex = 0;
static const NSUInteger kWhatOptionSelectedMonthsReportIndex = 1;
static const NSUInteger kWhatOptionSelectedConceptsReportIndex = 2;

static NSString * const kWhatOptionSelectedGlobalsReportInfoValue = @"globals_report";
static NSString * const kWhatOptionSelectedMonthsReportInfoValue = @"months_report";
static NSString * const kWhatOptionSelectedConceptsReportInfoValue = @"concepts_report";

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
    self.title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEWHAT_TITLE", @"");
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:NSLocalizedString(@"LTEXT_EXPORTCHOOSEWHAT_NEXTBUTTONTITLE", @"")
                                                                              style:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(readyButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

- (void)readyButtonPressed:(id)sender
{
    IAEOpenYear *openYear = [self.query findOpenYear];
    [[IAEExporter sharedExporter] exportYearDate:openYear.yearDate withUserConfiguration:self.userConfiguration];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return kNumberOfRowsInWhatSection;
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
    
    NSString *cellText = [NSString stringWithFormat:@"LTEXT_EXPORTCHOOSEWHAT_OPTION_%d", indexPath.row + 1];
    cell.textLabel.text = NSLocalizedString(cellText, @"");
    
    return cell;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = cell.accessoryType == UITableViewCellAccessoryCheckmark ? UITableViewCellAccessoryNone : UITableViewCellAccessoryCheckmark;
        
    [self updateUserConfiguration];
    [self updateReadyButton];
}

- (void)updateUserConfiguration
{
    NSMutableSet *whatUserInfoValues = [NSMutableSet set];
    NSArray *optionsIndexPathInWhatSection =  [self indexPathOfOptionSelected];
    for (NSIndexPath *indexPath in optionsIndexPathInWhatSection) {
        NSString *whatUserInfoValue = [self convertToUserInfoValueWhatOptionSelected:indexPath.row];
        [whatUserInfoValues addObject:whatUserInfoValue];
    }
    
    self.userConfiguration[@"what_options"] = [NSSet setWithSet:whatUserInfoValues];
}

- (void)updateReadyButton
{
    NSArray *optionsSelected = [self indexPathOfOptionSelected];
    
    const BOOL readyButtonEnabled = optionsSelected.count > 0;
    self.navigationItem.rightBarButtonItem.enabled = readyButtonEnabled;
}

- (NSString *)convertToUserInfoValueWhatOptionSelected:(NSUInteger)whatOptionSelected
{
    NSString *whatOptionUserInfoValue = nil;
    
    if (whatOptionSelected == kWhatOptionSelectedGlobalsReportIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedGlobalsReportInfoValue;
    } else if (whatOptionSelected == kWhatOptionSelectedMonthsReportIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedMonthsReportInfoValue;
    } else if (whatOptionSelected == kWhatOptionSelectedConceptsReportIndex) {
        whatOptionUserInfoValue = kWhatOptionSelectedConceptsReportInfoValue;
    }

    return whatOptionUserInfoValue;
}

- (NSArray *)indexPathOfOptionSelected
{
    NSMutableArray *options = [NSMutableArray array];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *indexPathOfCell = [self.tableView indexPathForCell:cell];
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            [options addObject:indexPathOfCell];
        }
    }
    
    NSArray *retOptions = [NSArray arrayWithArray:options];
    return retOptions;
}

@end
