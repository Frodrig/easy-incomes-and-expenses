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

static const NSUInteger kNumberOfSections = 2;
static const NSUInteger kIncomesSection = 0;
static const NSUInteger kExpenseSection = 1;

@interface IAEFavoriteConceptsViewController ()

@property (strong, nonatomic) NSMutableArray *favoriteIncomes;
@property (strong, nonatomic) NSMutableArray *favoriteExpenses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationItem *navItem;
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
    if (self.initOptions & FC_ADD) {
        [self enableAddOption];
    }
    
    if (self.initOptions & FC_REMOVE) {
        [self enableRemoveOption];
    }
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
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tableViewCell"];
    CategoryType categoryTypeOfIndexPath = [self findCategoryTypeOfIndexPath:indexPath];
    NSArray *favoriteContainer = [self findFavoriteContainerOfType:categoryTypeOfIndexPath];
    NSDictionary *favoriteItem = favoriteContainer[indexPath.row];
    cell.textLabel.text = favoriteItem[@"category"];
    cell.detailTextLabel.text = favoriteItem[@"value"];
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
    [self tableView:tableView setCellSelected:YES forRowAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tableView:tableView setCellSelected:NO forRowAtIndexPath:indexPath];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = section == kIncomesSection ? NSLocalizedString(@"LTEXT_CATEGORYTYPEINCOME_NAME", @"") : NSLocalizedString(@"LTEXT_CATEGORYTYPEEXPENSE_NAME", @"");
    
    return title;
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

@end
