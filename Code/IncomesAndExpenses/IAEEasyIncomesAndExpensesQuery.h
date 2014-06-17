//
//  IAEEasyIncomesAndExpensesQuery.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEEasyIncomesAndExpensesQueryDataSource.h"

@class IAEOpenYear;
@class IAEConcept;
@class IAECategory;
@class IAEContextView;

@interface IAEEasyIncomesAndExpensesQuery : NSObject

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesQueryDataSource> dataSource;

- (BOOL)isEditModeActive;
- (BOOL)isReportModeActive;
- (BOOL)isCalculatorOpen;
- (BOOL)isCalculatorClosed;
- (BOOL)isCalculatorInHideMode;
- (BOOL)isCalculatorInVisibleMode;
- (BOOL)isActualSelectedContextAMonth;

- (BOOL)existConceptsInActualSelectedContext;

- (UICollectionView *)findConceptsCollectionView;

- (IAEOpenYear *)findOpenYear;
- (IAEMonth *)findActualSelectedMonth;

- (BOOL)isActualSelectedContextTheYearOpen;

- (BOOL)isNoteModeActiveInConcepts;

- (BOOL)isTheBalancesOptionSelectedInReportMenu;
- (BOOL)isTheIncomesOptionSelectedInReportMenu;
- (BOOL)isTheExpensesOptionSelectedInReportMenu;

- (BOOL)isReportMenuViewSelectedWithTheOptionIndex:(NSUInteger)optionIndex;
- (NSUInteger)findCurrentOptionIndexSelectedInReportMenuView;

- (NSArray *)findIncomesCategoriesOfActualSelectedContextView;
- (NSArray *)findExpensesCategoriesOfActualSelectedContextView;
- (NSArray *)findAllCategoriesForActualSelectedContext;

- (NSArray *)findAllOrdererMonthsWithConceptsOfOpenYear;

- (NSUInteger)findNumberOfConceptsOfActualSelectedContextUsingSectionForYearContext:(NSInteger)section;
- (IAEConcept *)findConceptAtIndexPath:(NSIndexPath *)indexPath;

- (NSDecimalNumber *)findIncomesOfActualSelectedContextView;
- (NSDecimalNumber *)findExpensesOfActualSelectedContextView;
- (NSDecimalNumber *)findMaxValueOfAllCategoriesForActualSelectedContext;
- (NSDecimalNumber *)findMaxValueForActualSelectedContextForCategoryType:(CategoryType)categoryType;

- (id)findModelObjectOfActualSelectedContextView;

- (NSString *)findDayOfTheWeekNameFromConcept:(IAEConcept *)concept;

- (CGSize)findMainViewSize;

- (NSString *)findInActualOpenYearMonthNameWithMonthIndex:(NSUInteger)monthIndex inShortForm:(BOOL)shortForm;

- (BOOL)isDayModeActiveForConcepts;

- (IAECategory *)findCategoryOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell;
- (CategoryType)findCategoryTypeOfConceptCell:(IAEEditModeConceptCollectionViewCell *)cell;
- (NSUInteger)findTodayMonthContextViewGlobalIndexInSelectorContextView;
- (NSUInteger)findTodayMonthIndex;
- (IAEMonth *)findMonthOfPresentDay;
- (IAEMonth *)findMonthForOpenYearAtIndex:(NSUInteger)index;
- (NSArray *)allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:(NSIndexPath *)indexPath;
- (IAEConcept *)findConceptOfCell:(UICollectionViewCell *)cell;
- (IAEEditModeConceptCollectionViewCell *)findConceptCellOfConcept:(IAEConcept *)concept;
- (IAEContextView *)findActualSelectedMonthContextView;
- (IAEContextView *)findOpenYearContextView;
- (IAEContextView *)findContextViewAtGlobalPosition:(NSUInteger)globalPosition;
- (BOOL)categorySelectorViewControllerWasLaunchedFromCategoryButton;
- (BOOL)categorySelectorViewControllerWasLaunchedFromConcept;
- (IAEContextView *)findActualSelectedContext;
- (NSArray *)findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type;
- (NSUInteger)findDayOfTheMonthForConceptCell:(IAEEditModeConceptCollectionViewCell *)cell;
- (IAEEditModeConceptCollectionViewCell *)findConceptCollectionCellWithMenuModeActive;

@end
