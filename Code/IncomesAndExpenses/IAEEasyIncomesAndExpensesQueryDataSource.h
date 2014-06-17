//
//  IAEEasyIncomesAndExpensesQueryDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 17/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryDefs.h"
#import "IAEEditModeConceptCollectionViewCell.h"

@class IAEEasyIncomesAndExpensesQuery;
@class IAETextRawSelectorMenuView;
@class IAEMonth;
@class IAECalculatorViewController;
@class IAETextRawSelectorMenuView;

@protocol IAEEasyIncomesAndExpensesQueryDataSource <NSObject>

- (UISegmentedControl *)modeSegmentedControlForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;
- (IAECalculatorViewController *)calculatorViewControllerForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;

- (IAETextRawSelectorMenuView *)contextMenuViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;
- (IAETextRawSelectorMenuView *)reportMenuViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;

- (NSArray *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery allConceptsSortedAsAppropriateFromActualSelectedContextWithIndexPath:(NSIndexPath *)indexPath;

- (UICollectionView *)findConceptsCollectionViewForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;
- (CGSize)findMainViewSizeForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;
- (IAEMonth *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery  findMonthForOpenYearAtIndex:(NSUInteger)index;
- (NSArray *)easyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery  findCategoriesOfActualSelectedContextViewWithType:(CategoryType)type;
- (GlobalModeType)findGlobalModeTypeForConceptsEditModeForEasyIncomesAndExpensesQuery:(IAEEasyIncomesAndExpensesQuery *)easyIncomesAndExpensesQuery;

@end
