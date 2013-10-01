//
//  IAEHelperReportAreaViewDataSource.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "IAEHelperReportAreaViewDataSource.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEReportAreaView.h"
#import "IAENumberUtils.h"
#import "IAEColorHelper.h"
#import "IAECategory.h"
#import "IAECurrencyManager.h"
#import "IAEYear.h"
#import "IAEMonth.h"

@interface IAEHelperReportAreaViewDataSource()

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> iaeViewControllerQuery;
@property (nonatomic, strong) NSArray *allIncomeCategoriesOfActualContextCache;
@property (nonatomic, strong) NSArray *allExpenseCategoriesOfActualContextCache;
@property (nonatomic) CGFloat maxValueOfItemsCache;

@end

@implementation IAEHelperReportAreaViewDataSource

static NSString * const kLTextIncomeCategoryTypeName = @"LTEXT_CATEGORYTYPEINCOME_NAME";
static NSString * const kLTextExpenseCategoryTypeName = @"LTEXT_CATEGORYTYPEEXPENSE_NAME";

#pragma mark - Init

- (id)initWithEasyIncomesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query
{
    self = [super init];
    if (self) {
        NSAssert(query, @"");
        _iaeViewControllerQuery = query;
    }
    
    return self;
}

- (id)init
{
    NSAssert(0, @"");
    return nil;
}

#pragma mark - IAEReportAreaViewDataSource

- (BOOL)showNoItemsLabelIfAppropiateInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    BOOL anyConceptForActualContextView = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:0] > 0;
    
    return anyConceptForActualContextView;
}

- (NSUInteger)numberOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    NSUInteger number = 0;
    
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        number = [self.iaeViewControllerQuery findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:0] > 0 ? 2 : 0;
    } else if ([self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu]) {
        number = [self.iaeViewControllerQuery findIncomesCategoriesOfActualSelectedContextView].count;
    } else if ([self.iaeViewControllerQuery isTheExpensesOptionSelectedInReportMenu]) {
        number = [self.iaeViewControllerQuery findExpensesCategoriesOfActualSelectedContextView].count;
    }
    
    return number;
}

- (CGFloat)maxValueOfItemsInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    return self.maxValueOfItemsCache;
}

- (void)reloadAllItemsWillBeginInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    [self beginCategoryConceptSearchModeInActualContext];
    [self createAllCategoriesCache];
    [self createMaxValueOfItemsCache];
}

- (void)createAllCategoriesCache
{
    // Cacheamos categorias en modo ingresos y gastos
    const BOOL findAllIncomeCategories = [self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu];
    const BOOL findAllExpenseCategories = [self.iaeViewControllerQuery isTheExpensesOptionSelectedInReportMenu];
    
    id modelObj = [self.iaeViewControllerQuery findModelObjectOfActualSelectedContextView];
    if (findAllIncomeCategories) {
        self.allIncomeCategoriesOfActualContextCache = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:IncomeCategory];
    }
    
    if (findAllExpenseCategories) {
        self.allExpenseCategoriesOfActualContextCache = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:ExpenseCategory];
    }
}

- (void)createMaxValueOfItemsCache
{
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        NSDecimalNumber *incomes = [self.iaeViewControllerQuery findIncomesOfActualSelectedContextView];
        NSDecimalNumber *expenses = [self.iaeViewControllerQuery findExpensesOfActualSelectedContextView];
        self.maxValueOfItemsCache = [[IAENumberUtils maxValueOfNumber:incomes andNumber:expenses] floatValue];
    } else {
        CategoryType categoryType = [self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu] ? IncomeCategory : ExpenseCategory;
        NSDecimalNumber *maxDecimalValue = [self.iaeViewControllerQuery findMaxValueForActualSelectedContextForCategoryType:categoryType];
        self.maxValueOfItemsCache = maxDecimalValue.floatValue;
    }
}

- (void)beginCategoryConceptSearchModeInActualContext
{
    id modelObj = [self.iaeViewControllerQuery findModelObjectOfActualSelectedContextView];
    [modelObj beginCategoryConceptSearchMode];
}

- (void)reloadAllItemsDidEndInReportAreaView:(IAEReportAreaView *)reportAreaView
{
    [self endCategoryConceptSearchModeInActualContext];
    [self releaseAllCategoriesCache];
    [self releaseMaxValueOfItemsCache];
}

- (void)releaseAllCategoriesCache
{
    self.allExpenseCategoriesOfActualContextCache = nil;
    self.allIncomeCategoriesOfActualContextCache = nil;
}

- (void)releaseMaxValueOfItemsCache
{
    self.maxValueOfItemsCache = 0;
}

- (void)endCategoryConceptSearchModeInActualContext
{
    id modelObj = [self.iaeViewControllerQuery findModelObjectOfActualSelectedContextView];
    [modelObj endCategoryConceptSearchMode];
}

- (UIColor *)reportAreaView:(IAEReportAreaView *)reportAreaView colorRepresentationOfItemWithIndex:(NSUInteger)itemIndex
{
    UIColor *color = nil;
    
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        color = itemIndex == 0 ? [IAEColorHelper colorForEconomicIncomeValue] : [IAEColorHelper colorForEconomicExpenseValue];
    } else if ([self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu]) {
        color = [IAEColorHelper colorForEconomicIncomeValue];
    } else if ([self.iaeViewControllerQuery isTheExpensesOptionSelectedInReportMenu]) {
        color = [IAEColorHelper colorForEconomicExpenseValue];
    }
    
    return color;
}

- (CGFloat)reportAreaView:(IAEReportAreaView *)reportAreaView valueOfItemWithIndex:(NSUInteger)itemIndex 
{
    CGFloat valueOfItem = 0;
    
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        NSDecimalNumber *decimalValue = itemIndex == 0 ? [self.iaeViewControllerQuery findIncomesOfActualSelectedContextView] :
                                                         [self.iaeViewControllerQuery findExpensesOfActualSelectedContextView];
        valueOfItem = [decimalValue floatValue];
    } else {
        BOOL incomesOptionSelected = [self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu];
        NSArray *categories = incomesOptionSelected ? self.allIncomeCategoriesOfActualContextCache : self.allExpenseCategoriesOfActualContextCache;
        IAECategory *category = categories[itemIndex];
        id modelObj = [self.iaeViewControllerQuery findModelObjectOfActualSelectedContextView];
        NSDecimalNumber *balance = [modelObj balanceOfAllConceptsOfCategory:category];
        valueOfItem = [balance floatValue];
    }
    
    return valueOfItem;
}

- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView titleOfItemWithIndex:(NSUInteger)itemIndex
{
    NSString *title = nil;
    BOOL incomeValue =  NO;
    NSDecimalNumber *value = nil;
    
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        incomeValue = itemIndex == 0;
        value = incomeValue ? [self.iaeViewControllerQuery findIncomesOfActualSelectedContextView] :
                              [self.iaeViewControllerQuery findExpensesOfActualSelectedContextView];
    } else {
        id modelObj = [self.iaeViewControllerQuery findModelObjectOfActualSelectedContextView];
        incomeValue = [self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu];
        NSArray *categories = incomeValue ? self.allIncomeCategoriesOfActualContextCache : self.allExpenseCategoriesOfActualContextCache;
        IAECategory *category = categories[itemIndex];
        value = [modelObj sumAllAmountOfCategories:@[category]];
    }
    
    if (!incomeValue) {
        NSString *minusOne = [NSNumber numberWithFloat:-1].stringValue;
        value = [value decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:minusOne]];
    }
    
    title = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:value];

    return title;
}

- (NSString *)reportAreaView:(IAEReportAreaView *)reportAreaView subtitleOfItemWithIndex:(NSUInteger)itemIndex
{
    NSString *subtitle = nil;
    
    if ([self.iaeViewControllerQuery isTheBalancesOptionSelectedInReportMenu]) {
        subtitle = itemIndex == 0 ? NSLocalizedString(kLTextIncomeCategoryTypeName, @"") : NSLocalizedString(kLTextExpenseCategoryTypeName, @"");
    } else {
        CategoryType categoryType = [self.iaeViewControllerQuery isTheIncomesOptionSelectedInReportMenu] ? IncomeCategory : ExpenseCategory;
        NSArray *categories = categoryType == IncomeCategory ? self.allIncomeCategoriesOfActualContextCache : self.allExpenseCategoriesOfActualContextCache;
        IAECategory *category = categories[itemIndex];
        subtitle =  [category localizedTag];
    }
    
    return subtitle;
}

@end
