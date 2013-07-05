//
//  IAECategorySelectorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategorySelectorViewController.h"
#import "IAECategoryStore.h"
#import "IAECategoryTableViewCell.h"
#import "IAECategory.h"
#import "IAECategorySelectorViewControllerDelegate.h"

const NSUInteger INCOME_SEGMENTED_INDEX = 0;
const NSUInteger EXPENSE_SEGMENTED_INDEX = 1;

@interface IAECategorySelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;

@end

@implementation IAECategorySelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureCategoriesTableView];
}

- (void)configureCategoriesTableView
{
    [self.categoriesTableView registerNib:[UINib nibWithNibName:@"IAECategoryTableViewCell" bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:@"CategoryTableViewCell"];
    
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
}

#pragma mark - Control Events

- (IBAction)addCategoryButtonPressed:(id)sender
{
    
}

- (IBAction)categorySegmentedControlPressed:(id)sender
{
    [self.categoriesTableView reloadData];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.delegate categorySelectorViewController:self didSelectCategory:[self categoryOfCellAtIndexPath:indexPath]];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView dequeueReusableCellWithIdentifier:@"CategoryTableViewCell"
                                                                                                                forIndexPath:indexPath];
    [self configureTableViewCell:cell withCategory:[self categoryOfCellAtIndexPath:indexPath]];
    
    return cell;
}

- (IAECategory *)categoryOfCellAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryType categoryTypeSelected = [self categoryTypeSelectedInCategorySegmentedControl];
    NSArray *categories = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryTypeSelected];
    IAECategory *category = [categories objectAtIndex:indexPath.row];
    
    return category;
}

- (void)configureTableViewCell:(IAECategoryTableViewCell *)cell withCategory:(IAECategory *)category
{
    NSDictionary *attributes = [self createAttributeDictionaryForCategoryNameAttributeText];
    cell.categoryLabel.attributedText = [[NSAttributedString alloc] initWithString:[category description]
                                                                        attributes:attributes];
}

- (NSDictionary *)createAttributeDictionaryForCategoryNameAttributeText
{
    NSDictionary *attributes =  @{NSFontAttributeName: [self createFontForCategoryName],
                                  NSForegroundColorAttributeName: [UIColor blackColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForCategoryName
{
    return [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:31];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    CategoryType categoryTypeSelected = [self categoryTypeSelectedInCategorySegmentedControl];
    NSInteger retNumber = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryTypeSelected].count;
    
    return retNumber;
}

- (CategoryType)categoryTypeSelectedInCategorySegmentedControl
{
    CategoryType categoryType = IncomeCategory;
    if (self.categorySegmentedControl.selectedSegmentIndex == EXPENSE_SEGMENTED_INDEX) {
        categoryType = ExpenseCategory;
    }
    
    return categoryType;
}

@end
