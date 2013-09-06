//
//  IAEEasyIncomesAndExpensesViewControllerQueries.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryDefs.h"

@class IAEYear;
@class IAEMonth;
@class IAEConcept;
@class IAETextRawSelectorMenuView;

@protocol IAEEasyIncomesAndExpensesViewControllerQuery <NSObject>

- (UICollectionView *)findConceptsCollectionView;

- (IAEYear *)findOpenYear;
- (IAEMonth *)findActualSelectedMonth;

- (BOOL)isActualSelectedContextTheYearOpen;

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

- (BOOL)isDayModeActiveForConcepts;

@end
