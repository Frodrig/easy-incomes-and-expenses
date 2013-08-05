//
//  IAEConcept.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAEMonth.h"


@implementation IAEConcept

@dynamic amount;
@dynamic date;
@dynamic dayOfTheMonth;
@dynamic detailDescription;
@dynamic category;
@dynamic month;

- (NSComparisonResult)compare:(IAEConcept *)concept
{
    return [[NSNumber numberWithDouble:self.date] compare:[NSNumber numberWithDouble:concept.date]];
}

- (NSDecimalNumber *)amountWithSign
{
    NSDecimalNumber *retAmount = self.amount;
    if ([self.category isExpenseCategory]) {
        retAmount = [retAmount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    }
    
    return retAmount;
}

- (BOOL)canAssignSignedValue:(NSDecimalNumber *)signedValue
{
    BOOL retCanAssign = YES;
    
    NSComparisonResult compareToZero = [signedValue compare:[NSDecimalNumber zero]];
    if (compareToZero == NSOrderedAscending) {
        retCanAssign = self.category.categoryType == ExpenseCategory;
    } else if (compareToZero == NSOrderedDescending) {
        retCanAssign = self.category.categoryType == IncomeCategory;
    }
    
    return retCanAssign;
}

@end
