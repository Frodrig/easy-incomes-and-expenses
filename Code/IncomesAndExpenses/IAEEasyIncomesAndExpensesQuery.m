//
//  IAEEasyIncomesAndExpensesQuery.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEasyIncomesAndExpensesQuery.h"
#import "IAEEasyIncomesAndExpensesQueryDataSource.h"
#import "IAECalculatorViewController.h"
#import "IAETextRawSelectorMenuView.h"
#import "IAEEasyIncomesAndExpensesViewControllerDefs.h"
#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEDateHelper.h"
#import "IAEOpenYear.h"
#import "IAEMonth.h"
#import "IAEYear.h"
#import "IAEBook.h"
#import "IAEConcept.h"

@interface IAEEasyIncomesAndExpensesQuery()

@end

@implementation IAEEasyIncomesAndExpensesQuery

- (BOOL)isEditModeActive
{
    BOOL isEditMode = [self.dataSource modeSegmentedControlForEasyIncomesAndExpensesQuery:self].selectedSegmentIndex == kSegmentedControlIndexEditMode;
    
    return isEditMode;
}

- (BOOL)isReportModeActive
{
    BOOL isReportMode = [self.dataSource modeSegmentedControlForEasyIncomesAndExpensesQuery:self].selectedSegmentIndex == kSegmentedControlIndexReportMode;
    
    return isReportMode;
}

- (BOOL)isCalculatorOpen
{
    return [[self.dataSource calculatorViewControllerForEasyIncomesAndExpensesQuery:self] isOpen];
}

- (BOOL)isCalculatorClosed
{
    return [[self.dataSource calculatorViewControllerForEasyIncomesAndExpensesQuery:self] isClosed];
}

- (BOOL)isCalculatorInHideMode
{
    return [[self.dataSource calculatorViewControllerForEasyIncomesAndExpensesQuery:self] isInHideMode];
}

- (BOOL)isCalculatorInVisibleMode
{
    return [[self.dataSource calculatorViewControllerForEasyIncomesAndExpensesQuery:self] isInVisibleMode];
}

- (NSString *)findInActualOpenYearMonthNameWithMonthIndex:(NSUInteger)monthIndex inShortForm:(BOOL)shortForm
{
    IAEOpenYear *openYear = [self findOpenYear];
    IAEMonth *month = [openYear.months objectAtIndex:monthIndex - 1];
    NSString *monthName = [IAEDateHelper findMonthNameStringWithMonthIndex:month.month inShortForm:shortForm];
    
    return monthName;
}

- (IAEOpenYear *)findOpenYear
{
    return [[IAEBook sharedBook] findActualOpenYear];
}

- (IAEMonth *)findActualSelectedMonth
{
    IAEMonth *month = nil;
    if ([self.dataSource contextMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected != kGlobalIndexForYearInContextScrollView) {
        NSUInteger actualMonthIndex = [self.dataSource contextMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected - 1;
        month = [self.dataSource easyIncomesAndExpensesQuery:self findMonthForOpenYearAtIndex:actualMonthIndex];
    }
    
    return month;
}

- (BOOL)isTheBalancesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfBalancesOption];
    
    return isSelected;
}

- (BOOL)isTheIncomesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfIncomesOption];
    
    return isSelected;
}

- (BOOL)isTheExpensesOptionSelectedInReportMenu
{
    BOOL isSelected = [self isReportMenuViewSelectedWithTheOptionIndex:kReportMenuIndexOfExpensesOption];
    
    return isSelected;
}

- (BOOL)isReportMenuViewSelectedWithTheOptionIndex:(NSUInteger)optionIndex
{
    BOOL isSelected = optionIndex == [self findCurrentOptionIndexSelectedInReportMenuView];
    
    return isSelected;
}

- (NSUInteger)findCurrentOptionIndexSelectedInReportMenuView
{
    return [self.dataSource reportMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected;
}

- (NSDecimalNumber *)findMaxValueForActualSelectedContextForCategoryType:(CategoryType)categoryType
{
    NSAssert(categoryType != InvalidCategory, @"");
    
    id modelObject = [self findModelObjectOfActualSelectedContextView];
    NSArray *allCategories = categoryType == IncomeCategory ? [self findIncomesCategoriesOfActualSelectedContextView] : [self findExpensesCategoriesOfActualSelectedContextView];
    NSDecimalNumber *maxValue = [self findForModelObject:modelObject maxBalanceValueOfCategories:allCategories];
    
    return maxValue;
}

- (NSDecimalNumber *)findMaxValueOfAllCategoriesForActualSelectedContext
{
    id modelObject = [self findModelObjectOfActualSelectedContextView];
    NSArray *allCategories = [self findAllCategoriesForActualSelectedContext];
    NSDecimalNumber *maxValue = [self findForModelObject:modelObject maxBalanceValueOfCategories:allCategories];
    
    return maxValue;
}

- (NSDecimalNumber *)findForModelObject:(id)modelObject maxBalanceValueOfCategories:(NSArray *)categories
{
    NSDecimalNumber *maxValue = [NSDecimalNumber zero];
    
    for (IAECategory *category in categories) {
        NSDecimalNumber *categoryValue = [modelObject balanceOfAllConceptsOfCategory:category];
        if ([categoryValue compare:maxValue] == NSOrderedDescending) {
            maxValue = categoryValue;
        }
    }
    
    return maxValue;
}

- (NSArray *)findAllCategoriesForActualSelectedContext
{
    NSArray *incomeCategories = [self findIncomesCategoriesOfActualSelectedContextView];
    NSArray *expenseCategories = [self findExpensesCategoriesOfActualSelectedContextView];
    NSSet *allCategories = [NSSet setWithArray:incomeCategories];
    allCategories = [allCategories setByAddingObjectsFromArray:expenseCategories];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"categoryType" ascending:YES];
    NSArray *allSortedCategories = [allCategories sortedArrayUsingDescriptors:@[sortDescriptor]];
    
    return allSortedCategories;
}

- (NSDecimalNumber *)findIncomesOfActualSelectedContextView
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSDecimalNumber *incomes = [modelObj incomes];
    
    return incomes;
}

- (NSDecimalNumber *)findExpensesOfActualSelectedContextView
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSDecimalNumber *expenses = [modelObj expenses];
    
    return expenses;
}

- (NSArray *)findIncomesCategoriesOfActualSelectedContextView
{
    NSArray *categories = [self.dataSource easyIncomesAndExpensesQuery:self findCategoriesOfActualSelectedContextViewWithType:IncomeCategory];
    
    return categories;
}

- (NSArray *)findExpensesCategoriesOfActualSelectedContextView
{
    NSArray *categories = [self.dataSource easyIncomesAndExpensesQuery:self findCategoriesOfActualSelectedContextViewWithType:ExpenseCategory];
    
    return categories;
}

- (id)findModelObjectOfActualSelectedContextView
{
    id modelObject;
    
    if ([self isActualSelectedContextTheYearOpen]) {
        modelObject = [self findOpenYear];
    } else if ([self isActualSelectedContextAMonth]) {
        modelObject = [self findActualSelectedMonth];
    }
    
    return modelObject;
}

- (BOOL)isActualSelectedContextTheYearOpen
{
    return [self.dataSource contextMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected == kGlobalIndexForYearInContextScrollView ? YES : NO;
}

- (BOOL)isNoteModeActiveInConcepts
{
    const GlobalModeType globalModeType = [self.dataSource findGlobalModeTypeForConceptsEditModeForEasyIncomesAndExpensesQuery:self];
    return globalModeType == GlobalModeTypeNote;
}

- (BOOL)isActualSelectedContextAMonth
{
    return [self isActualSelectedContextTheYearOpen] ? NO : YES;
}

- (CGSize)findMainViewSize
{
    return [self.dataSource findMainViewSizeForEasyIncomesAndExpensesQuery:self];
}

- (NSArray *)findAllOrdererMonthsWithConceptsOfOpenYear
{
    IAEOpenYear *openYear = [self findOpenYear];
    NSArray *months = [openYear findAllOrdererMonthsWithConcepts];
    
    return months;
}

- (UICollectionView *)findConceptsCollectionView
{
    return [self.dataSource findConceptsCollectionViewForEasyIncomesAndExpensesQuery:self];
}

- (IAEConcept *)findConceptAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *concepts = [self.dataSource easyIncomesAndExpensesQuery:self allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:indexPath];
    IAEConcept *concept = nil;
    if (concepts.count > 0 && indexPath.row < concepts.count) {
        concept = [concepts objectAtIndex:indexPath.row];
    }
    
    return concept;
}

- (NSUInteger)findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:(NSInteger)section
{
    NSUInteger numberOfConcepts = 0;
    if ([self isActualSelectedContextAMonth]) {
        IAEMonth *month = [self findActualSelectedMonth];
        numberOfConcepts = month.concepts.count;
    } else {
        NSArray *months = [self findAllOrdererMonthsWithConceptsOfOpenYear];
        if (months.count > 0) {
            IAEMonth *month = months[section];
            numberOfConcepts = month.concepts.count;
        }
    }
    
    return numberOfConcepts;
}

- (BOOL)existConceptsInActualSelectedContext
{
    NSUInteger numberOfConcepts = [self findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:0];
    
    return numberOfConcepts > 0;
}

- (BOOL)isDayModeActiveForConcepts
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive];
}

- (NSString *)findDayOfTheWeekNameFromConcept:(IAEConcept *)concept
{
    NSUInteger dayOfTheWeekIndex = [IAEDateHelper findDayOfTheWeekIndexFromYearDate:concept.month.year.yearDate
                                                                         monthIndex:concept.month.month
                                                                   andDayOfTheMonth:concept.dayOfTheMonth];
    NSString *dayOfTheWeekName = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:dayOfTheWeekIndex inShortForm:NO];
    
    return dayOfTheWeekName;
}

@end
