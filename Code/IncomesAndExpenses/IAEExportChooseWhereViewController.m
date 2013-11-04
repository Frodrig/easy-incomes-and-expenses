//
//  IAEExportStepOneViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportChooseWhereViewController.h"
#import "IAEExportChooseMonthsViewController.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"

@interface IAEExportChooseWhereViewController ()

@end

@implementation IAEExportChooseWhereViewController

#pragma mark - Constants

static const NSUInteger kNumberOfExportOptions = 3;

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 24;

static const NSUInteger kOptionIndexPrint = 0;
static const NSUInteger kOptionIndexPDF = 1;
static const NSUInteger kOptionIndexCSV = 2;

static NSString * const kWherePrintKey = @"where_print";
static NSString * const kWherePDFKey = @"where_pdf";
static NSString * const kWhereCSVKey = @"where_csv";

#pragma mark - Properties

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
    self.title = NSLocalizedString(@"LTEXT_EXPORTCHOOSEWHERE_TITLE", @"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_EXPORTCHOOSEWHERE_NEXTBUTTONTITLE", @"")
                                                                              style:UIBarButtonSystemItemAction
                                                                             target:self
                                                                             action:@selector(nextStepButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem.enabled = NO;
}

#pragma mark - BarButtonsActions

- (void)cancelButtonPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)nextStepButtonPressed:(id)sender
{
    [self lauchChooseHowViewController];
}

- (void)lauchChooseHowViewController
{
    IAEExportChooseMonthsViewController *chooseMonthsViewController = [[IAEExportChooseMonthsViewController alloc] initWithNibName:nil bundle:nil];
    chooseMonthsViewController.userConfiguration = self.userConfiguration;
    chooseMonthsViewController.query = self.query;
    [self.navigationController pushViewController:chooseMonthsViewController animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return kNumberOfExportOptions;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.font = [UIFont fontWithName:kFamilyFontNameForCells size:kFamilyFontSizeForCells];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.imageView.contentMode = UIViewContentModeCenter;
    }
    
    // Configure the cell...
    NSString *lTextExportOption = [NSString stringWithFormat:@"LTEXT_EXPORTCHOOSEWHERE_OPTION_%d", indexPath.row + 1];
    cell.textLabel.text = NSLocalizedString(lTextExportOption, @"");
    if (indexPath.row == kOptionIndexPrint) {
        cell.imageView.image = [UIImage imageNamed:@"743-printer"];
    } else if (indexPath.row == kOptionIndexPDF || indexPath.row == kOptionIndexCSV) {
        cell.imageView.image = [UIImage imageNamed:@"738-document-1"];
    }
    
    return cell;
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
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
        NSString *keyForCellAtIndexPath = [self convertCellIndexPathToKey:cellIndexPath];
        self.userConfiguration[keyForCellAtIndexPath] = cell.accessoryType == UITableViewCellAccessoryCheckmark ? [NSNumber numberWithBool:YES] : [NSNumber numberWithBool:NO];
    }
}

- (NSString *)convertCellIndexPathToKey:(NSIndexPath *)indexPath
{    
    NSString *key = nil;
    if (indexPath.row == kOptionIndexPrint) {
        key = [NSString stringWithString:kWherePrintKey];
    } else if (indexPath.row == kOptionIndexPDF) {
        key = [NSString stringWithString:kWherePDFKey];
    } else if (indexPath.row == kOptionIndexCSV) {
        key = [NSString stringWithString:kWhereCSVKey];
    }
    
    return key;
}

- (void)updateNextStepButton
{
    self.navigationItem.rightBarButtonItem.enabled = [self isAnyWhereToExportMarked];
}

- (BOOL)isAnyWhereToExportMarked
{
    const BOOL isAnyWhereMarked = [self.userConfiguration[kWherePrintKey] boolValue] ||
                                  [self.userConfiguration[kWherePDFKey] boolValue] ||
                                  [self.userConfiguration[kWhereCSVKey] boolValue];
    
    return isAnyWhereMarked;
}
 
@end
