//
//  IAEYearObject.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CategoryDefs.h"

@class IAECategory;

@protocol IAEYearObject <NSObject>

- (NSDecimalNumber *)expenses;
- (NSDecimalNumber *)incomes;
- (NSDecimalNumber *)balance;
- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category;

- (void)beginCategoryConceptSearchMode;
- (void)endCategoryConceptSearchMode;

- (NSArray *)findAllOrdererMonthsWithConcepts;
- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllConcepts;
- (NSArray *)findAllConceptsSortedByEntryInstant;
- (NSArray *)findAllConceptsSortedByDay;
- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type;
- (NSUInteger)findNumberOfConcepts;

- (NSString *)yearDateAsString;

@end
