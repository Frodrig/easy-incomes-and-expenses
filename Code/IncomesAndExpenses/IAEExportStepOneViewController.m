//
//  IAEExportStepOneViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExportStepOneViewController.h"

@interface IAEExportStepOneViewController ()

@property (nonatomic, strong) NSSet *selectedExportDestinations;

@end

@implementation IAEExportStepOneViewController

#pragma mark - Constants

static const NSUInteger kNumberOfExportOptions = 3;

static NSString * const kFamilyFontNameForCells = @"HelveticaNeue-Light";
static const NSUInteger kFamilyFontSizeForCells = 24;

static const NSUInteger kOptionIndexPrint = 1;
static const NSUInteger kOptionIndexPDF = 2;
static const NSUInteger kOptionIndexCSV = 3;

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
    self.title = NSLocalizedString(@"LTEXT_EXPORTSTEPONE_TITLE", @"");
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                          target:self
                                                                                          action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"LTEXT_EXPORTSTEPONE_NEXTBUTTONTITLE", @"")
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
    const NSUInteger optionIndex = indexPath.row + 1;
    NSString *lTextExportOption = [NSString stringWithFormat:@"LTEXT_EXPORTSTEPONE_OPTION_%d", optionIndex];
    cell.textLabel.text = NSLocalizedString(lTextExportOption, @"");
    if (optionIndex == kOptionIndexPrint) {
        cell.imageView.image = [UIImage imageNamed:@"743-printer"];
    } else if (optionIndex == kOptionIndexPDF || optionIndex == kOptionIndexCSV) {
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
    
    [self updateSelectedExportDestinations]; 
    [self updateNextStepButton];
}

- (void)updateSelectedExportDestinations
{
    NSMutableSet *selectedExportDestinations = [NSMutableSet set];
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark) {
            NSIndexPath *cellIndexPath = [self.tableView indexPathForCell:cell];
            [selectedExportDestinations addObject:@(cellIndexPath.row)];
        }
    }
    
    self.selectedExportDestinations = [NSSet setWithSet:selectedExportDestinations];
}

- (void)updateNextStepButton
{
    self.navigationItem.rightBarButtonItem.enabled = self.selectedExportDestinations.count > 0;
}
 
@end
