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

static const NSUInteger kNumberOfSections = 2;
static const NSUInteger kIncomesSection = 0;
static const NSUInteger kExpenseSection = 1;

@interface IAEFavoriteConceptsViewController ()

@property (strong, nonatomic) NSMutableArray *favoriteIncomes;
@property (strong, nonatomic) NSMutableArray *favoriteExpenses;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end

@implementation IAEFavoriteConceptsViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self createFavoriteConcepts];
        [self sortFavoriteConcepts];
    }
    return self;
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
    
    // Do any additional setup after loading the view from its nib.
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"tableViewCell"];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableViewCell"];
    CategoryType categoryTypeOfIndexPath = [self findCategoryTypeOfIndexPath:indexPath];
    NSArray *favoriteContainer = [self findFavoriteContainerOfType:categoryTypeOfIndexPath];
    NSDictionary *favoriteItem = favoriteContainer[indexPath.row];
    cell.textLabel.text = favoriteItem[@"category"];
    
    return cell;
}

- (CategoryType)findCategoryTypeOfIndexPath:(NSIndexPath *)indexPath
{
    CategoryType categoryType = indexPath.section == kIncomesSection ? IncomeCategory : ExpenseCategory;
    
    return categoryType;
}

#pragma mark - TableView Delegate

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = section == kIncomesSection ? NSLocalizedString(@"LTEXT_CATEGORYTYPEINCOME_NAME", @"") : NSLocalizedString(@"LTEXT_CATEGORYTYPEEXPENSE_NAME", @"");
    
    return title;
}

@end
