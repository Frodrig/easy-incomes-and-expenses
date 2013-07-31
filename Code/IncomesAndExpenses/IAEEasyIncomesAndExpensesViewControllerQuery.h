//
//  IAEEasyIncomesAndExpensesViewControllerQueries.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEYear;
@class IAETextRawSelectorMenuView;

@protocol IAEEasyIncomesAndExpensesViewControllerQuery <NSObject>

- (IAEYear *)findOpenYear;

- (BOOL)isTheBalancesOptionSelectedInReportMenu;
- (BOOL)isTheIncomesOptionSelectedInReportMenu;
- (BOOL)isTheExpensesOptionSelectedInReportMenu;

- (BOOL)isReportMenuViewSelectedWithTheOptionIndex:(NSUInteger)optionIndex;
- (NSUInteger)findCurrentOptionIndexSelectedInReportMenuView;

- (NSArray *)findIncomesCategoriesOfActualSelectedContextView;
- (NSArray *)findExpensesCategoriesOfActualSelectedContextView;
- (NSSet *)findAllCategoriesForActualSelectedContext;

- (NSDecimalNumber *)findIncomesOfActualSelectedContextView;
- (NSDecimalNumber *)findExpensesOfActualSelectedContextView;
- (NSDecimalNumber *)findMaxValueOfAllCategoriesForActualSelectedContext;

- (id)findModelObjectOfActualSelectedContextView;

- (CGSize)findMainViewSize;

@end
