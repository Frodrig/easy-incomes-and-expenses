//
//  IAEFavoriteConceptsViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEFavoriteConceptsViewController.h"
#import "IAEFavoriteConceptsStock.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "IAEFavoriteConceptsViewControllerDelegate.h"
#import "IAEStrokeAnimatableLineView.h"
#import "IAEFavoriteConceptsTableHeader.h"
#import "UIView+LoadFromXib.h"
#import "IAEValueDecoratorView.h"
#import "IAEColorHelper.h"
#import "IAENumberFormatterManager.h"
#import "Flurry.h"

static NSString * const kCategoryKey = @"category";
static NSString * const kValueKey = @"value";

static const NSUInteger kNumberOfSections = 2;
static const NSUInteger kIncomesSection = 0;
static const NSUInteger kExpenseSection = 1;

static const CGFloat kDurationStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimation = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimation = 1.0;
static const NSUInteger kTypeStrokeAnimation = STROKEANIMATABLE_TYPE_THIN;

static const CGFloat kHeaderViewHeight = 54.0;

static NSString * const kAdviceNoFavoriteFontFamily = @"HelveticaNeue-Italic";
static const CGFloat kAdviceNoFavoriteFontSize = 18;
static NSString * const kCategoryFavoriteFontFamily = @"HelveticaNeue-Thin";
static const CGFloat kCategoryFavoriteFontSize = 21;
static NSString * const kValueFavoriteFontFamily = @"HelveticaNeue";
static const CGFloat kValueFavoriteFontSize = 18;

static const CGFloat kDelayToExecuteRemoveFavoriteCell = 0.1;

static const CGFloat kAlphaForCellStroked = 0.2;

@interface IAEFavoriteConceptsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (nonatomic, weak) IAEFavoriteConceptsTableHeader *incomeHeaderView;
@property (nonatomic, weak) IAEFavoriteConceptsTableHeader *expenseHeaderView;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) NSIndexPath *strokedCellIndexPath;
@property (strong, nonatomic) NSMutableArray *favoriteIncomes;
@property (strong, nonatomic) NSMutableArray *favoriteExpenses;
@property (nonatomic) NSUInteger initOptions;

@end

@implementation IAEFavoriteConceptsViewController

#pragma mark - Init

- (instancetype)initWithOptions:(NSUInteger)options
{
    NSAssert(options, @"");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initOptions = options;

        [self initStrokeAnimatableView];
        [self createFavoriteConcepts];
        [self sortFavoriteConcepts];
    }

    return self;
}

- (void)initStrokeAnimatableView
{
    _strokeAnimatableLineView = [[IAEStrokeAnimatableLineView alloc] init];
    _strokeAnimatableLineView.durationOfStrokeAnimation = kDurationStrokeAnimation;
    _strokeAnimatableLineView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimation
                                                              alpha:kColorWhiteAlphaComponentForStrokeAnimation];
    _strokeAnimatableLineView.strokeType = kTypeStrokeAnimation;
    _strokeAnimatableLineView.delegate = self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    NSAssert(0, @"");
    
    return nil;
}

- (void)createFavoriteConcepts
{
    _favoriteExpenses = [NSMutableArray array];
    _favoriteIncomes = [NSMutableArray array];
    
    NSDictionary *favorites = [IAEFavoriteConceptsStock sharedInstance].favorites;
    for (NSString *category in favorites) {
        CategoryType categoryType = [[IAECategoryStore sharedCategoryStore] findTypeOfCategoryTag:category];
        if (categoryType != InvalidCategory) {
            NSMutableArray *container = [self findFavoriteContainerOfType:categoryType];
            for (NSString *categoryValue in favorites[category]) {
                [container addObject:@{kCategoryKey : category, kValueKey : categoryValue}];
            }
        }
    }
}

- (void)sortFavoriteConcepts
{
    NSComparisonResult (^sortBlock)(id obj1, id obj2) = ^(id obj1, id obj2) {
        NSDictionary *dicObj1 = obj1;
        NSDictionary *dicObj2 = obj2;
        NSComparisonResult result = [dicObj1[kCategoryKey] compare:dicObj2[kCategoryKey]];
        if (result == NSOrderedSame) {
            result = [dicObj1[kValueKey] compare:dicObj2[kValueKey]];
        }
        
        return result;
    };
    
    _favoriteExpenses = [NSMutableArray arrayWithArray:[_favoriteExpenses sortedArrayUsingComparator:sortBlock]];
    _favoriteIncomes = [NSMutableArray arrayWithArray:[_favoriteIncomes sortedArrayUsingComparator:sortBlock]];
}

- (NSMutableArray *)findFavoriteContainerOfType:(CategoryType)categoryType
{
    NSAssert(categoryType != InvalidCategory, @"");
    return categoryType == IncomeCategory ? _favoriteIncomes : _favoriteExpenses;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureNavigationBar];
    [self configureWithOptionsPassed];
    [self configureTableView];
}

- (void)configureNavigationBar
{
    self.navItem.title = NSLocalizedString(@"LTEXT_FAVORITE_NAVIGATIONITEM_TITLE", @"");
}

- (void)configureWithOptionsPassed
{
    if ([self isAddOptionEnabled]) {
        [self enableAddOption];
    }
    
    if ([self isRemoveOptionEnabled]) {
        [self enableRemoveOption];
    } else {
        self.navItem.leftBarButtonItem = nil;
    }
}

- (BOOL)isAddOptionEnabled
{
    return self.initOptions & FC_ADD;
}

- (BOOL)isRemoveOptionEnabled
{
    return self.initOptions & FC_REMOVE;
}

- (void)enableAddOption
{
    NSAssert(self.navItem, @"");

    self.navItem.rightBarButtonItem = [[UIBarButtonItem alloc]  initWithTitle:NSLocalizedString(@"LTEXT_CALCULATOR_BUTTON_ADD", @"")
                                                                        style:UIBarButtonItemStylePlain
                                                                       target:self
                                                                       action:@selector(addButtonPressed:)];
    self.navItem.rightBarButtonItem.enabled = NO;
}

- (void)enableRemoveOption
{
    _swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognizerEvent:)];
    [self.tableView addGestureRecognizer:self.swipeGestureRecognizer];
}

- (void)configureTableView
{
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
    self.tableView.allowsMultipleSelection = YES;
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self numberOfRowsForSection:section];
}

- (NSUInteger)numberOfRowsForSection:(NSUInteger)section
{
    const NSInteger numberOfRows = section == kIncomesSection ? self.favoriteIncomes.count : self.favoriteExpenses.count;
    
    return MAX(numberOfRows, 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self isNoFavoritePinsAtIndexPath:indexPath]) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"tableViewAdviceCell"];
        [self configureAdviceNoFavoriteConceptCell:cell inTableView:tableView atIndexPath:indexPath];
    } else {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableViewCell"];
        NSDictionary *favoriteItem = [self findFavoriteItemAtIndexPath:indexPath];
        [self configureFavoriteConceptCell:cell inTableView:tableView atIndexPath:indexPath withFavoriteItem:favoriteItem];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.alpha = 1.0;
    
    return cell;
}

- (BOOL)isNoFavoritePinsAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *favoriteContainer = [self findFavoriteContainerAtIndexPath:indexPath];
    const BOOL noFavoritePins = favoriteContainer.count == 0;

    return noFavoritePins;
}

- (NSDictionary *)findFavoriteItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *favoriteContainer = [self findFavoriteContainerAtIndexPath:indexPath];
    NSDictionary *favoriteItem = favoriteContainer[indexPath.row];

    return favoriteItem;
}

- (NSMutableArray *)findFavoriteContainerAtIndexPath:(NSIndexPath *)indexPath
{
    CategoryType categoryTypeOfIndexPath = [self findCategoryTypeOfIndexPath:indexPath];
    NSMutableArray *favoriteContainer = [self findFavoriteContainerOfType:categoryTypeOfIndexPath];
    
    return favoriteContainer;
}

- (void)configureAdviceNoFavoriteConceptCell:(UITableViewCell *)cell inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.font = [UIFont fontWithName:kAdviceNoFavoriteFontFamily size:kAdviceNoFavoriteFontSize];
    cell.textLabel.text = NSLocalizedString(@"LTEXT_FAVORITE_NOFAVORITESADVICE", @"");
}

- (void)configureFavoriteConceptCell:(UITableViewCell *)cell inTableView:(UITableView *)tableView atIndexPath:(NSIndexPath *)indexPath withFavoriteItem:(NSDictionary *)favoriteItem
{
    cell.accessoryType = [self accesoryTypeOfTableView:tableView forIndexPath:indexPath];

    cell.textLabel.font = [UIFont fontWithName:kCategoryFavoriteFontFamily size:kCategoryFavoriteFontSize];
    cell.textLabel.text = favoriteItem[kCategoryKey];
    
    cell.detailTextLabel.text = [self convertToEconomicStringValueItem:favoriteItem[kValueKey] ofType:[self economicValueTypeInTableView:tableView forIndexPath:indexPath]];
    cell.detailTextLabel.font = [UIFont fontWithName:kValueFavoriteFontFamily size:kValueFavoriteFontSize];
    cell.detailTextLabel.textColor = indexPath.section == kIncomesSection ? [IAEColorHelper colorForEconomicIncomeValue] : [IAEColorHelper colorForEconomicExpenseValue];
}

- (NSString *)convertToEconomicStringValueItem:(NSString *)value ofType:(EconomicValueType)type
{
    NSDecimalNumber *valueNumber = [NSDecimalNumber decimalNumberWithString:value];
    if (type == ECONOMIC_EXPENSE_VALUE) {
        NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithString:@"-1"];
        valueNumber = [valueNumber decimalNumberByMultiplyingBy:minusOne];
    }
    
    NSString *valueNumberString = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:valueNumber];
    return valueNumberString;
}

- (EconomicValueType)economicValueTypeInTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    return indexPath.section == kIncomesSection ? ECONOMIC_INCOME_VALUE : ECONOMIC_EXPENSE_VALUE;
}

- (UITableViewCellAccessoryType)accesoryTypeOfTableView:(UITableView *)tableView forIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellAccessoryType accesoryType = [self isSelectedCellInTableView:tableView forRowAtIndexPath:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return accesoryType;
}

- (BOOL)isSelectedCellInTableView:(UITableView *)tableView forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *selectedCells = [tableView indexPathsForSelectedRows];
    NSUInteger indexOfSelectedCell = [selectedCells indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSIndexPath *indexPathIt = obj;
        *stop = [indexPathIt compare:indexPath];
        return *stop;
    }];
    
    const BOOL isSelected = selectedCells && indexOfSelectedCell != NSNotFound;
    return isSelected;
}

- (CategoryType)findCategoryTypeOfIndexPath:(NSIndexPath *)indexPath
{
    CategoryType categoryType = indexPath.section == kIncomesSection ? IncomeCategory : ExpenseCategory;
    
    return categoryType;
}

#pragma mark - TableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isActiveCheckForSelectAndDeselectEventsAtIndexPath:indexPath]) {
        [self tableView:tableView setCellSelected:YES forRowAtIndexPath:indexPath andUpdateAddAndSelectButtons:YES];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isActiveCheckForSelectAndDeselectEventsAtIndexPath:indexPath]) {
        [self tableView:tableView setCellSelected:NO forRowAtIndexPath:indexPath andUpdateAddAndSelectButtons:YES];
    }
}

- (BOOL)isActiveCheckForSelectAndDeselectEventsAtIndexPath:(NSIndexPath *)indexPath
{
    const BOOL check = ![self isNoFavoritePinsAtIndexPath:indexPath] && [self isAddOptionEnabled];
    
    return check;
}

- (void)tableView:(UITableView *)tableView setCellSelected:(BOOL)selected forRowAtIndexPath:(NSIndexPath *)indexPath andUpdateAddAndSelectButtons:(BOOL)updateAddAndSelectButtons
{
    if (selected) {
        [tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    } else {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    if (updateAddAndSelectButtons) {
        [self updateAddAndSelectButtonsForSection:indexPath.section];
    }
}

- (void)updateAddAndSelectButtonsForSection:(NSInteger)section
{
    [self refreshHeaderAtSection:section];
    [self updateAddButtonEnabledState];
}

- (void)updateAddButtonEnabledState
{
    const BOOL rowsSelected = [self.tableView indexPathsForSelectedRows].count > 0;
    self.navItem.rightBarButtonItem.enabled = rowsSelected;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    IAEFavoriteConceptsTableHeader *header = [self createAndSaveViewForHeaderInSection:section inTableView:tableView];
    [self configureHeader:header forSection:section inTableView:tableView];
    
    return header;
}

- (IAEFavoriteConceptsTableHeader *)createAndSaveViewForHeaderInSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    IAEFavoriteConceptsTableHeader *header = (IAEFavoriteConceptsTableHeader *)[UIView viewFromXib:@"IAEFavoriteConceptsTableHeader" withOwner:self];
    if (section == kIncomesSection) {
        self.incomeHeaderView = header;
    } else if (section == kExpenseSection) {
        self.expenseHeaderView = header;
    }
    
    return header;
}

- (void)configureHeader:(IAEFavoriteConceptsTableHeader *)header forSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    if ([self isAddOptionEnabled]) {
        // TODO si no hay elementos estado desactivado
        if ([self isNoFavoritePinsAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:section]]) {
            header.selectButtonState = SelectButtonStateHide;
        } else if ([self someSelectionsButNotAllSelectionsActiveForSection:section inTableView:tableView] ||
                   [self noSelectionsActiveForSection:section inTableView:tableView]) {
            header.selectButtonState =  SelectButtonStateSelectAll;
        } else if ([self allSelectionsActiveForSection:section inTableView:tableView]) {
            header.selectButtonState = SelectButtonStateDeselectAll;
        } else {
            NSAssert(0, @"");
        }
    } else {
        header.selectButtonState = SelectButtonStateHide;
    }
    
    if (section == kIncomesSection) {
        header.decoratorValueType = ECONOMIC_INCOME_VALUE;
        [header vinculeForTouchEventTarget:self withSelector:@selector(buttonSelectDeselectAllIncomesPressed:)];
    } else if (section == kExpenseSection) {
        header.decoratorValueType = ECONOMIC_EXPENSE_VALUE;
        [header vinculeForTouchEventTarget:self withSelector:@selector(buttonSelectDeselectAllExpensesPressed:)];
    }
}

- (void)buttonSelectDeselectAllIncomesPressed:(id)sender
{
    [self executeSelectDeselectActionOfButtonState:self.incomeHeaderView.selectButtonState forSection:kIncomesSection];
}

- (void)buttonSelectDeselectAllExpensesPressed:(id)sender
{
    [self executeSelectDeselectActionOfButtonState:self.expenseHeaderView.selectButtonState forSection:kExpenseSection];
}

- (void)executeSelectDeselectActionOfButtonState:(SelectButtonState)state forSection:(NSUInteger)section
{
    [self.tableView beginUpdates];
    
    const NSUInteger numberOfRows = [self numberOfRowsForSection:section];
    if (numberOfRows > 0) {
        for (NSUInteger rowIt = 0; rowIt < numberOfRows; ++rowIt) {
            [self tableView:self.tableView setCellSelected:state == SelectButtonStateSelectAll ? YES : NO forRowAtIndexPath:[NSIndexPath indexPathForRow:rowIt inSection:section] andUpdateAddAndSelectButtons:NO];
        }
        [self updateAddAndSelectButtonsForSection:section];
    }
    
    [self.tableView endUpdates];
}

- (BOOL)existSelectionsForSection:(NSUInteger)section inTableView:(UITableView *)tableView
{
    BOOL retExistSelections = NO;
    
    for (NSIndexPath *indexPath in tableView.indexPathsForSelectedRows) {
        if (indexPath.section == section) {
            retExistSelections = YES;
            break;
        }
    }
    
    return retExistSelections;
}

- (BOOL)allSelectionsActiveForSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    NSArray *selectionsOfSection = [self selectionsForSection:section inTableView:tableView];
    return selectionsOfSection.count == [self numberOfRowsForSection:section];
}

- (BOOL)someSelectionsButNotAllSelectionsActiveForSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    NSArray *selectionsOfSection = [self selectionsForSection:section inTableView:tableView];
    return selectionsOfSection.count > 0 && selectionsOfSection.count < [self numberOfRowsForSection:section];
}


- (BOOL)noSelectionsActiveForSection:(NSInteger)section inTableView:(UITableView *)tableView
{
    NSArray *selectionsOfSection = [self selectionsForSection:section inTableView:tableView];
    return selectionsOfSection.count == 0;
}

- (NSArray *)selectionsForSection:(NSUInteger)section inTableView:(UITableView *)tableView
{
    NSArray *selectionsOfSection = [tableView.indexPathsForSelectedRows filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSIndexPath *indexPath = evaluatedObject;
        return indexPath.section == section;
    }]];
    
    return selectionsOfSection;
}

- (void)changeSelectDeselectStateOfHeaderView:(IAEFavoriteConceptsTableHeader *)headerView
{
    if (headerView.selectButtonState == SelectButtonStateSelectAll) {
        headerView.selectButtonState = SelectButtonStateDeselectAll;
    } else if (headerView.selectButtonState == SelectButtonStateDeselectAll) {
        headerView.selectButtonState = SelectButtonStateSelectAll;
    }
}

- (void)refreshHeaderAtSection:(NSInteger)section
{
    [self configureHeader:[self findHeaderViewForSection:section] forSection:section inTableView:self.tableView];
}

- (IAEFavoriteConceptsTableHeader *)findHeaderViewForSection:(NSInteger)section
{
    return section == kIncomesSection ? self.incomeHeaderView : self.expenseHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return kHeaderViewHeight;
}

#pragma mark - NavigationItem Events

- (void)addButtonPressed:(id)sender
{
    NSArray *favoriteIncomes = [self findFavoriteIncomesSelected];
    NSArray *favoriteExpenses = [self findFavoriteExpensesSelected];
    [self.delegate favoriteConceptsViewController:self didPressedAddOptionWithFavoriteIncomes:favoriteIncomes andExpenses:favoriteExpenses];
    
    [Flurry logEvent:@"Favorites_ADD" withParameters:@{@"incomes_total": @(favoriteIncomes.count),
                                                       @"expenses_total": @(favoriteExpenses.count)}];
}

- (NSArray *)findFavoriteIncomesSelected
{
    NSArray *favorites = [self findFavoriteConceptsSelectedOfType:IncomeCategory];
    return favorites;
}

- (NSArray *)findFavoriteExpensesSelected
{
    NSArray *favorites = [self findFavoriteConceptsSelectedOfType:ExpenseCategory];
    return favorites;
}

- (NSArray *)findFavoriteConceptsSelectedOfType:(CategoryType)categoryType
{
    NSMutableArray *conceptsFound = [NSMutableArray array];
    
    const NSUInteger sectionToCheck = categoryType == IncomeCategory ? kIncomesSection : kExpenseSection;
    
    NSArray *selectedIndexPaths = [self.tableView indexPathsForSelectedRows];
    for (NSIndexPath *indexPath in selectedIndexPaths) {
        if (indexPath.section == sectionToCheck) {
            NSDictionary *item = [self findFavoriteItemAtIndexPath:indexPath];
            [conceptsFound addObject:@{kCategoryKey: item[kCategoryKey],
                                       kValueKey : item[kValueKey]}];
        }
    }
    
    return [NSArray arrayWithArray:conceptsFound];
}

#pragma mark - Swipe Gesture Recognizer

- (void)swipeGestureRecognizerEvent:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    self.strokedCellIndexPath = [self indexPathForStrokeFavoriteAtPoint:location];
    if (self.strokedCellIndexPath) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.strokedCellIndexPath];
        [UIView animateWithDuration:self.strokeAnimatableLineView.durationOfStrokeAnimation animations:^{
            cell.alpha = kAlphaForCellStroked;
        }];
        [self.strokeAnimatableLineView doStrokeOverTheView:cell];
    }
}

- (NSIndexPath *)indexPathForStrokeFavoriteAtPoint:(CGPoint)location
{
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:location];
    NSMutableArray *favoriteConceptContainer = [self findFavoriteContainerAtIndexPath:indexPath];
    if (favoriteConceptContainer.count == 0) {
        indexPath = 0;
    }

    return indexPath;
}

#pragma mark - StrokeAnimatabeLinewView Delegate

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view;
{
    [self performSelector:@selector(doRemoveFavoriteCell) withObject:nil afterDelay:kDelayToExecuteRemoveFavoriteCell];
}

- (void)doRemoveFavoriteCell
{
    NSMutableArray *favoriteConceptContainer = [self findFavoriteContainerAtIndexPath:self.strokedCellIndexPath];
    NSDictionary *favoriteItem = [favoriteConceptContainer objectAtIndex:self.strokedCellIndexPath.row];
    
    [self.delegate favoriteConceptsViewController:self willRemoveFavoriteWithCategory:favoriteItem[kCategoryKey] andValue:favoriteItem[kValueKey]];
    [[IAEFavoriteConceptsStock sharedInstance] removeAndSaveFavoriteWithCategory:favoriteItem[kCategoryKey] andValue:favoriteItem[kValueKey]];
    [favoriteConceptContainer removeObjectAtIndex:self.strokedCellIndexPath.row];
    [self.delegate favoriteConceptsViewController:self didRemoveFavoriteWithCategory:favoriteItem[kCategoryKey] andValue:favoriteItem[kValueKey]];
    
    [self.tableView beginUpdates];
    [self.tableView deleteRowsAtIndexPaths:@[self.strokedCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    if (favoriteConceptContainer.count == 0) {
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:self.strokedCellIndexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.tableView endUpdates];
    
    self.strokedCellIndexPath = nil;
    [self.strokeAnimatableLineView resetStroke];
}

#pragma mark - Bar Button Events

- (IBAction)doneButtonPressed:(id)sender
{
    [self.delegate doneButtonWasPressedInfavoriteConceptsViewController:self];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
