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

@interface IAECategorySelectorViewController ()

@property (weak, nonatomic) IBOutlet UITableView *categoriesTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGestureRecognizer;
@property (nonatomic, weak) IAECategoryTableViewCell *cellSelectedForContextualMenu;
@property (nonatomic) NSUInteger actions;
@property (weak, nonatomic) IBOutlet UINavigationItem *navigationToolBar;
@property (nonatomic) CategoryType initialCategoryType;

@end

@implementation IAECategorySelectorViewController

static const NSUInteger kIncomeSegmentedIndex = 0;
static const NSUInteger kExpenseSegmentedIndex = 1;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"No deberia de instanciarse este init");
    self = nil;
    
    return self;
}

// Designated
- (id)initWithExtraActions:(NSUInteger)actions andSelectedCategoryType:(CategoryType)category
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self initActions:actions];
        [self initLongTapGestureRecognizer];
        _initialCategoryType = category;
    }
    
    return self;
}

- (id)initWithAllExtraActionsAndSelectedCategoryType:(CategoryType)category;
{
    self = [self initWithExtraActions:CATEGORYSELECTOR_EXTRAACTION_ALL_ACTIONS andSelectedCategoryType:category];
    if (self) {
        // ...
    }
    
    return self;
}

- (id)initWithAllExtraActionsExceptSelectionAndSelectedCategoryType:(CategoryType)category
{
    NSUInteger categoryActions = CATEGORYSELECTOR_EXTRAACTION_ADD |
                                 CATEGORYSELECTOR_EXTRAACTION_DONE |
                                 CATEGORYSELECTOR_EXTRAACTION_DELETE |
                                 CATEGORYSELECTOR_EXTRAACTION_RENAME;
    self = [self initWithExtraActions:categoryActions andSelectedCategoryType:category];
    if (self) {
        // ...
    }
    
    return self;
}

- (void)initActions:(NSUInteger)actions
{
    _actions = actions;
}

- (void)initLongTapGestureRecognizer
{
    if ([self renameActionFlagEnabled] || [self deleteActionFlagEnabled]) {
        _longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecogzinerEvent:)];
        _longPressGestureRecognizer.numberOfTapsRequired = 0;
        _longPressGestureRecognizer.numberOfTouchesRequired = 1;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationItem];
    [self configureCategoriesTableView];
    [self changeToCategory:self.initialCategoryType];
}

- (void)configureNavigationItem
{
    if (![self addActionFlagEnabled]) {
        self.navigationToolBar.rightBarButtonItem = nil;
    }
    
    if (![self doneActionFlagEnabled]) {
        self.navigationToolBar.leftBarButtonItem = nil;
    }
}

- (BOOL)categorySelectionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION;
}

- (BOOL)addActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_ADD;
}

- (BOOL)doneActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_DONE;
}

- (BOOL)renameActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_RENAME;
}

- (BOOL)deleteActionFlagEnabled
{
    return self.actions & CATEGORYSELECTOR_EXTRAACTION_DELETE;
}

- (void)configureCategoriesTableView
{
    [self.categoriesTableView registerNib:[UINib nibWithNibName:@"IAECategoryTableViewCell" bundle:[NSBundle mainBundle]]
                   forCellReuseIdentifier:@"CategoryTableViewCell"];
    self.categoriesTableView.allowsSelection = [self categorySelectionFlagEnabled];
    self.categoriesTableView.delegate = self;
    self.categoriesTableView.dataSource = self;
    
    if (self.longPressGestureRecognizer) {
        [self.categoriesTableView addGestureRecognizer:self.longPressGestureRecognizer];
    }
}

- (void)reloadData
{
    [self.categoriesTableView reloadData];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (void)changeToCategory:(CategoryType)category
{
    CategoryType actualCategory = [self categoryTypeSelectedInCategorySegmentedControl];
    if (actualCategory != category) {
        NSAssert(category != InvalidCategory, @"");
        self.categorySegmentedControl.selectedSegmentIndex = [self segmentedIndexForCategoryType:category];
        
        [self reloadData];
    }
}

- (NSInteger)segmentedIndexForCategoryType:(CategoryType)category
{
    NSInteger segmentedIndex = category == IncomeCategory ? kIncomeSegmentedIndex : kExpenseSegmentedIndex;
    
    return segmentedIndex;
}

#pragma mark - Control Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self.delegate doneButtonWasPressedInCategorySelectorViewController:self];
}

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
    if (self.categorySegmentedControl.selectedSegmentIndex == kExpenseSegmentedIndex) {
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
        
        UIMenuController *menu = [UIMenuController sharedMenuController];
        menu.menuItems = [self createMenuItemContainerForMenuAction];
        [menu setTargetRect:self.cellSelectedForContextualMenu.frame inView:self.cellSelectedForContextualMenu];
        [menu setMenuVisible:YES animated:YES];
    }
}

- (NSArray *)createMenuItemContainerForMenuAction
{
    NSArray *menuItems = [NSArray array];
    menuItems = [self addMenuItemAction:[self createMenuItemForRenameActionIfProceed] usingMenuItems:menuItems];
    menuItems = [self addMenuItemAction:[self createMenuItemForDeleteActionIfProceed] usingMenuItems:menuItems];
    
    return menuItems;
}

- (UIMenuItem *)createMenuItemForRenameActionIfProceed
{
    UIMenuItem *menuItem = nil;
    if ([self renameActionFlagEnabled]) {
        menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Rename", @"") action:@selector(renameCategoryMenuSelected:)];
    }
    
    return menuItem;
}

- (NSArray *)addMenuItemAction:(UIMenuItem *)menuItem usingMenuItems:(NSArray *)menuItems
{
    NSAssert(menuItems, @"");
    if (menuItem) {
        menuItems = [menuItems arrayByAddingObject:menuItem];
    }
    
    return [menuItems copy];
}

- (UIMenuItem *)createMenuItemForDeleteActionIfProceed
{
    UIMenuItem *menuItem = nil;
    if ([self deleteActionFlagEnabled]) {
        menuItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", @"") action:@selector(deleteCategoryMenuSelected:)];
    }
    
    return menuItem;
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
