//
//  IAEHelpConfigureStartMonthSelectorTableViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 30/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelpConfigureStartMonthSelectorTableViewController.h"
#import "IAEHelpIndexViewControllerDelegate.h"
#import "IAEDateHelper.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@interface IAEHelpConfigureStartMonthSelectorTableViewController ()

@end

@implementation IAEHelpConfigureStartMonthSelectorTableViewController


#pragma mark - Constants

static const NSUInteger kNumberOfMonths = 12;

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 22;

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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)configureNavigationController
{
    self.title = NSLocalizedString(@"LTEXT_STARTMONTHSELECTORVC_TITLE", @"");
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                           target:self
                                                                                           action:@selector(doneButtonPressed:)];
     */
}


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
    return kNumberOfMonths;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self newCellForTableView:tableView forRowAtIndexPath:indexPath];
    [self configureTableViewCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

- (UITableViewCell *)newCellForTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
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

- (void)configureTableViewCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    const MonthType month = [self monthOfIndexPath:indexPath];
    cell.textLabel.text = [IAEDateHelper findMonthNameStringWithMonthIndex:month inShortForm:NO];
    const BOOL cellWithTheActualInitialMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth] == month;
    cell.accessoryType = cellWithTheActualInitialMonth ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
}

- (MonthType)monthOfIndexPath:(NSIndexPath *)indexPath
{
    const MonthType month = (MonthType)(indexPath.row + 1);

    return month;
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    const MonthType monthOfSelectedIndexPath = [self monthOfIndexPath:indexPath];
    const MonthType actualStartMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
    if (monthOfSelectedIndexPath != actualStartMonth) {
        NSIndexPath *previousSelectedIndexPath = [self indexPathOfMonth:actualStartMonth];
        UITableViewCell *previousSelectedCell = [tableView cellForRowAtIndexPath:previousSelectedIndexPath];
        previousSelectedCell.accessoryType = UITableViewCellAccessoryNone;
        
        UITableViewCell *newSelectedCell = [tableView cellForRowAtIndexPath:indexPath];
        newSelectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        [[NSUserDefaults standardUserDefaults] changeInitialMonthTo:monthOfSelectedIndexPath];
    }
}

- (NSIndexPath *)indexPathOfMonth:(MonthType)month
{
    NSAssert(month != InvalidMonth, @"");
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:month - 1 inSection:0];
    
    return indexPath;
}
 
@end
