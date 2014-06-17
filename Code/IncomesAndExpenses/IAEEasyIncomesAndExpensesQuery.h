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

@end
