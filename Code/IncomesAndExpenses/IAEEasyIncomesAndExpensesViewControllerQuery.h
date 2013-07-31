//
//  IAEEasyIncomesAndExpensesViewControllerQueries.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAEEasyIncomesAndExpensesViewControllerQuery <NSObject>

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

@end
