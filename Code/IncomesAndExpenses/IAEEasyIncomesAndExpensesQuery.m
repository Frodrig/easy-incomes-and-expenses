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
#import "IAESelectorContextView.h"
#import "IAEDateHelper.h"
#import "IAEOpenYear.h"
#import "IAEMonth.h"
#import "IAEYear.h"
#import "IAEBook.h"
#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAEContextView.h"

@interface IAEEasyIncomesAndExpensesQuery()

@end

@implementation IAEEasyIncomesAndExpensesQuery

#pragma mark - Global

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

#pragma mark - forViewController

- (IAECategory *)findCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAECategory *categoryOfConcept = concept.category;
    
    return categoryOfConcept;
}

- (CategoryType)findCategoryTypeOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    IAECategory *categoryOfConcept = concept.category;
    
    return categoryOfConcept.categoryType;
}

- (NSUInteger)findTodayMonthContextViewGlobalIndexInSelectorContextView
{
    NSUInteger todayMonthContextViewGlobalIndex = [self findTodayMonthIndex] + 1;
    
    return todayMonthContextViewGlobalIndex;
}

- (NSUInteger)findTodayMonthIndex
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *monthComponents = [gregorian components:NSCalendarUnitMonth fromDate:today];
    
    IAEOpenYear *openYear = [self findOpenYear];
    const NSUInteger todayLocalMonthIndex = [openYear findIndexOfMonth:(MonthType)(monthComponents.month)];
    
    return todayLocalMonthIndex;
}

- (IAEMonth *)findMonthOfPresentDay
{
    NSUInteger todayMonthIndex = [self findTodayMonthIndex];
    return [self findMonthForOpenYearAtIndex:todayMonthIndex];
}

- (IAEMonth *)findMonthForOpenYearAtIndex:(NSUInteger)index
{
    IAEOpenYear *year = [self findOpenYear];
    return [year.months objectAtIndex:index];
}

- (NSArray *)allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:(NSIndexPath *)indexPath
{
    IAEMonth *month = nil;
    if ([self isActualSelectedContextAMonth]) {
        month = [self findActualSelectedMonth];
    } else {
        NSArray *months = [self findAllOrdererMonthsWithConceptsOfOpenYear];
        month = months[indexPath.section];
    }
    
    NSArray *allConcepts = [self isDayModeActiveForConcepts] ? [month allConceptsSortedByDay] : [month allConceptsSortedByEntryInstant];
    
    return allConcepts;
}

- (IAEConcept *)findConceptOfCell:(UICollectionViewCell *)cell
{
    NSIndexPath *indexPathOfCell = [[self.dataSource conceptsCollectionViewForEasyIncomesAndExpensesQuery:self] indexPathForCell:cell];
    return [self findConceptAtIndexPath:indexPathOfCell];
}

- (IAEEditModeConceptCollectionViewCell *)findConceptCellOfConcept:(IAEConcept *)concept
{
    const BOOL dayMode = [self isDayModeActiveForConcepts];
    NSArray *concepts = dayMode ? [concept.month allConceptsSortedByDay] : [concept.month allConceptsSortedByEntryInstant];
    NSUInteger conceptIndex = [concepts indexOfObject:concept];
    NSIndexPath *indexPathOfCell = [NSIndexPath indexPathForRow:conceptIndex inSection:0];
    IAEEditModeConceptCollectionViewCell *cell = (IAEEditModeConceptCollectionViewCell*) [[self.dataSource conceptsCollectionViewForEasyIncomesAndExpensesQuery:self] cellForItemAtIndexPath:indexPathOfCell];
    
    NSAssert(cell, @"");
    return cell;
}

- (IAEContextView *)findActualSelectedMonthContextView
{
    return [self.dataSource contextMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected > 0 ? [self findContextViewAtGlobalPosition:[self.dataSource contextMenuViewForEasyIncomesAndExpensesQuery:self].currentOptionIndexSelected] : nil;
}

- (IAEContextView *)findOpenYearContextView
{
    return [self findContextViewAtGlobalPosition:0];
}

- (IAEContextView *)findContextViewAtGlobalPosition:(NSUInteger)globalPosition
{
    IAEContextView *contextView = [[self.dataSource selectorContextViewForEasyIncomesAndExpensesQuery:self] findContextViewAtIndex:globalPosition];
    
    return contextView;
}

- (BOOL)categorySelectorViewControllerWasLaunchedFromCategoryButton
{
    // Nota: Solo tendra sentido si realmente se ha lanzado
    const BOOL launchedFromCategoryButton = [self.dataSource currentPopoverForEasyIncomesAndExpensesQuery:self] == nil && [self.dataSource categorySelectorViewControllerForEasyIncomesAndExpensesQuery:self] != nil;
    
    return launchedFromCategoryButton;
}

- (BOOL)categorySelectorViewControllerWasLaunchedFromConcept
{
    return [self.dataSource currentPopoverForEasyIncomesAndExpensesQuery:self] != nil;
}

- (IAEContextView *)findActualSelectedContext
{
    IAEContextView *actualSelectedContext = nil;
    if ([self isActualSelectedContextAMonth]) {
        actualSelectedContext = [self findActualSelectedMonthContextView];
    } else {
        actualSelectedContext = [self findContextViewAtGlobalPosition:kGlobalIndexForYearInContextScrollView];
    }
    
    return actualSelectedContext;
}

- (NSArray *)findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type
{
    id modelObj = [self findModelObjectOfActualSelectedContextView];
    NSArray *categories = [modelObj findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:type];
    
    return categories;
}

- (NSUInteger)findDayOfTheMonthForConceptCell:(IAEEditModeConceptCollectionViewCell *)cell
{
    IAEConcept *concept = [self findConceptOfCell:cell];
    return concept.dayOfTheMonth;
}

- (IAEEditModeConceptCollectionViewCell *)findConceptCollectionCellWithMenuModeActive
{
    IAEEditModeConceptCollectionViewCell *retCell = nil;
    for (IAEEditModeConceptCollectionViewCell *cellIt in [self.dataSource conceptsCollectionViewForEasyIncomesAndExpensesQuery:self].visibleCells) {
        if (cellIt.menuModeActive) {
            retCell = cellIt;
            break;
        }
    }
    
    return retCell;
}

@end
