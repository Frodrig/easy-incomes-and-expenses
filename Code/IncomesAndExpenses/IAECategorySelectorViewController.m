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
#import "IAECategoryStore.h"
#import "IAEBook.h"
#import "IAECategorySelectorViewControllerDelegate.h"

const NSUInteger INCOME_SEGMENTED_INDEX = 0;
const NSUInteger EXPENSE_SEGMENTED_INDEX = 1;

@interface IAECategorySelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) IAECategoryTableViewCell *cellSelectedForContextualMenu;

@end

@implementation IAECategorySelectorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initLongTapGestureRecognizer];
    }
    return self;
}

- (void)initLongTapGestureRecognizer
{
    _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecogzinerEvent:)];
    _longPressGestureRecognizer.numberOfTapsRequired = 0;
    _longPressGestureRecognizer.numberOfTouchesRequired = 1;
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
    
    [self.categoriesTableView addGestureRecognizer:self.longPressGestureRecognizer];
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - Control Events

- (IBAction)addCategoryButtonPressed:(id)sender
{
    CategoryType actualCategoryType = [self categoryTypeSelectedInCategorySegmentedControl];
    [self.delegate categorySelectorViewController:self didSelectAddCategoryOfType:actualCategoryType];
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

#pragma mark - LongTapGestureRecognizer

- (void)longPressGestureRecogzinerEvent:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    [self launchContextualMenuOnCellUnderLongPressGestureRecognizer:longPressGestureRecognizer];
}

- (void)launchContextualMenuOnCellUnderLongPressGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    self.cellSelectedForContextualMenu = [self findCellUnderLongTapGestureRecognizer:longPressGestureRecognizer];
    if (self.cellSelectedForContextualMenu) {
        [self launchContextualMenuOnCellSelectedForContextualMenuIfCategoryOfCellIsNotGeneral];
    }
}

- (IAECategoryTableViewCell *)findCellUnderLongTapGestureRecognizer:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    CGPoint longPressLocation = [longPressGestureRecognizer locationInView:self.categoriesTableView];
    NSIndexPath *cellIndexPath = [self.categoriesTableView indexPathForRowAtPoint:longPressLocation];
    IAECategoryTableViewCell *cell = (IAECategoryTableViewCell *)[self.categoriesTableView cellForRowAtIndexPath:cellIndexPath];
    
    return cell;
}

- (void)launchContextualMenuOnCellSelectedForContextualMenuIfCategoryOfCellIsNotGeneral
{
    NSAssert(self.cellSelectedForContextualMenu, @"");
    
    if (![self isCellSelectedForContextualMenuGeneralCategory]) {
        [self becomeFirstResponder];
        
        UIMenuItem *deleteCategoryMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"")
                                                                        action:@selector(deleteCategoryMenuSelected:)];
        UIMenuItem *renameCategoryMenuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"")
                                                                        action:@selector(renameCategoryMenuSelected:)];
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = [NSArray arrayWithObjects:renameCategoryMenuItem, deleteCategoryMenuItem, nil];
        [menu setTargetRect:self.cellSelectedForContextualMenu.frame inView:self.cellSelectedForContextualMenu];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (BOOL)isCellSelectedForContextualMenuGeneralCategory
{
    IAECategory *category = [self categoryOfCellSelectedForContextualMenu];
    return [[IAECategoryStore sharedCategoryStore] isGeneralCategory:category];
}

#pragma mark - MenuController

- (void)deleteCategoryMenuSelected:(id)sender
{
    if ([self categoryOfCellSelectedHaveConcepts]) {
        [self launchAlertViewBeforeDeleteCategory];
    } else {
        [self removeCategoryOfCellSelected];
    }
}

- (BOOL)categoryOfCellSelectedHaveConcepts
{
    NSUInteger numberOfConceptsOfCategory = [self findNumberOfConceptsOfCategoryOfCellSelected];
    return numberOfConceptsOfCategory > 0;
}

- (NSUInteger)findNumberOfConceptsOfCategoryOfCellSelected
{
    IAECategory *category = [self categoryOfCellSelectedForContextualMenu];
    NSUInteger numConceptsOfCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category].count;
    
    return numConceptsOfCategory;
}

- (IAECategory *)categoryOfCellSelectedForContextualMenu
{
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:self.cellSelectedForContextualMenu.categoryLabel.text];
    return category;
}

- (void)launchAlertViewBeforeDeleteCategory
{
    UIAlertView *alertView = [[UIAlertView alloc]
                              initWithTitle:NSLocalizedString(@"Confirm remove", @"Advertenciai para confirmar el borrado de una categoria")
                              message:NSLocalizedString(@"There are one or more items with this category. If you remove this category the items will change to the general category associated.", @"Descripcion de lo que ocurrira al borrar una categoria")
                              delegate:self
                              cancelButtonTitle:NSLocalizedString(@"Cancel", @"Opcion para cancelar el borrado de una categoria")
                              otherButtonTitles:NSLocalizedString(@"Remove", @"Opcion para confirmar el borrado de una categoria"), nil];
    
    [alertView show];
}

- (void)removeCategoryOfCellSelected
{
    IAECategory *category = [self categoryOfCellSelectedForContextualMenu];
    [self.delegate categorySelectorViewController:self didSelectRemoveCategory:category];
}

- (void)renameCategoryMenuSelected:(id)sender
{
    IAECategory *category = [self categoryOfCellSelectedForContextualMenu];
    [self.delegate categorySelectorViewController:self didSelectedRenameCategory:category];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        [self removeCategoryOfCellSelected];
    }
}

@end
