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

static const NSUInteger kNumberOfSections = 2;
static const NSUInteger kIncomesSection = 0;
static const NSUInteger kExpenseSection = 1;

static const CGFloat kDurationStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimation = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimation = 1.0;
static const NSUInteger kTypeStrokeAnimation = STROKEANIMATABLE_TYPE_THIN;

static const CGFloat kHeaderViewHeight = 54.0;

@interface IAEFavoriteConceptsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureRecognizer;
@property (nonatomic, strong) NSIndexPath *strokedCellIndexPath;
@property (strong, nonatomic) NSMutableArray *favoriteIncomes;
@property (strong, nonatomic) NSMutableArray *favoriteExpenses;
@property (nonatomic) NSUInteger initOptions;

@end

@implementation IAEFavoriteConceptsViewController

#pragma mark - Properties

- (IAEStrokeAnimatableLineView *)strokeAnimatableLineView
{
    // ToDo: Refactor
    if (!_strokeAnimatableLineView) {
        _strokeAnimatableLineView = [[IAEStrokeAnimatableLineView alloc] init];
        _strokeAnimatableLineView.durationOfStrokeAnimation = kDurationStrokeAnimation;
        _strokeAnimatableLineView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimation
                                                                  alpha:kColorWhiteAlphaComponentForStrokeAnimation];
        _strokeAnimatableLineView.strokeType = kTypeStrokeAnimation;
        _strokeAnimatableLineView.delegate = self;
    }
    
    return _strokeAnimatableLineView;
}

#pragma mark - Init

- (instancetype)initWithOptions:(NSUInteger)options
{
    NSAssert(options, @"");
    
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _initOptions = options;
        // ToDo: Refactor
        [self createFavoriteConcepts];
        [self sortFavoriteConcepts];
    }
    return self;

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
        NSMutableArray *container = [self findFavoriteContainerOfType:categoryType];
        for (NSString *categoryValue in favorites[category]) {
            [container addObject:@{@"category" : category, @"value" : categoryValue}];
        }
    }
}

- (void)sortFavoriteConcepts
{
    NSComparisonResult (^sortBlock)(id obj1, id obj2) = ^(id obj1, id obj2) {
        NSDictionary *dicObj1 = obj1;
        NSDictionary *dicObj2 = obj2;
        NSComparisonResult result = [dicObj1[@"category"] compare:dicObj2[@"category"]];
        if (result == NSOrderedSame) {
            result = [dicObj1[@"value"] compare:dicObj2[@"value"]];
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
        
    [self configureWithOptions];
    [self configureTableView];
    
}

- (void)configureWithOptions
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
    NSLog(@"%@", self.navItem.title);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView DataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    const NSInteger numberOfRows = section == kIncomesSection ? self.favoriteIncomes.count : self.favoriteExpenses.count;
    
    return numberOfRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableViewCell"];
    CategoryType categoryTypeOfIndexPath = [self findCategoryTypeOfIndexPath:indexPath];
    NSArray *favoriteContainer = [self findFavoriteContainerOfType:categoryTypeOfIndexPath];
    NSDictionary *favoriteItem = favoriteContainer[indexPath.row];
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:21];
    cell.textLabel.text = favoriteItem[@"category"];
    NSDecimalNumber *valueNumber = [NSDecimalNumber decimalNumberWithString:favoriteItem[@"value"]];
    if (indexPath.section == kExpenseSection) {
        NSDecimalNumber *minusOne = [NSDecimalNumber decimalNumberWithString:@"-1"];
        valueNumber = [valueNumber decimalNumberByMultiplyingBy:minusOne];
    }
    cell.detailTextLabel.text = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:valueNumber];
    cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:18];
    cell.detailTextLabel.textColor = indexPath.section == kIncomesSection ? [IAEColorHelper colorForEconomicIncomeValue] : [IAEColorHelper colorForEconomicExpenseValue];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.accessoryType = [self isSelectedCellInTableView:tableView forRowAtIndexPath:indexPath] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    return cell;
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
    if ([self isAddOptionEnabled]) {
        [self tableView:tableView setCellSelected:YES forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self isAddOptionEnabled]) {
        [self tableView:tableView setCellSelected:NO forRowAtIndexPath:indexPath];
    }
}

- (void)tableView:(UITableView *)tableView setCellSelected:(BOOL)selected forRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
    
    [self updateAddButtonEnabledState];
}

- (void)updateAddButtonEnabledState
{
    const BOOL rowsSelected = [self.tableView indexPathsForSelectedRows].count > 0;
    self.navItem.rightBarButtonItem.enabled = rowsSelected;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    IAEFavoriteConceptsTableHeader *header = (IAEFavoriteConceptsTableHeader *)[UIView viewFromXib:@"IAEFavoriteConceptsTableHeader" withOwner:self];
    if (section == kIncomesSection) {
        header.title = NSLocalizedString(@"LTEXT_CATEGORYTYPEINCOME_NAME", @"");
        header.decoratorValueType = ECONOMIC_INCOME_VALUE;
    } else if (section == kExpenseSection) {
        header.title = NSLocalizedString(@"LTEXT_CATEGORYTYPEEXPENSE_NAME", @"");
        header.decoratorValueType = ECONOMIC_EXPENSE_VALUE;
    }
    
    return header;
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
            UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
            [conceptsFound addObject:@{@"category": cell.textLabel.text, @"value" : cell.detailTextLabel.text}];
        }
    }
    
    return [NSArray arrayWithArray:conceptsFound];
}

#pragma mark - Swipe Gesture Recognizer

- (void)swipeGestureRecognizerEvent:(UIGestureRecognizer *)gesture
{
    CGPoint location = [gesture locationInView:self.tableView];
    self.strokedCellIndexPath = [self.tableView indexPathForRowAtPoint:location];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.strokedCellIndexPath];
    [self.strokeAnimatableLineView doStrokeOverTheView:cell];
}

#pragma mark - StrokeAnimatabeLinewView Delegate

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view;
{
    // Remove
    NSMutableArray *favoriteConceptContainer = self.strokedCellIndexPath.section == kIncomesSection ? self.favoriteIncomes : self.favoriteExpenses;
    NSDictionary *favoriteItem = [favoriteConceptContainer objectAtIndex:self.strokedCellIndexPath.row];
    [self.delegate favoriteConceptsViewController:self willRemoveFavoriteWithCategory:favoriteItem[@"category"] andValue:favoriteItem[@"value"]];
    [[IAEFavoriteConceptsStock sharedInstance] removeAndSaveFavoriteWithCategory:favoriteItem[@"category"] andValue:favoriteItem[@"value"]];
    [favoriteConceptContainer removeObjectAtIndex:self.strokedCellIndexPath.row];
    [self.delegate favoriteConceptsViewController:self didRemoveFavoriteWithCategory:favoriteItem[@"category"] andValue:favoriteItem[@"value"]];

    [self.tableView deleteRowsAtIndexPaths:@[self.strokedCellIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
