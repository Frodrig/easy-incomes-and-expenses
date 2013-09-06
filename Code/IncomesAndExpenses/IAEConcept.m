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

#pragma mark - Class

+ (NSDecimalNumber *)maxCentinelConceptValue
{
    static NSDecimalNumber *maximumValue = nil;
    if (!maximumValue) {
        maximumValue = [NSDecimalNumber decimalNumberWithString:@"10000000000000"];
    }
    
    return maximumValue;
}

+ (NSDecimalNumber *)minCentinelConceptValue
{
    static NSDecimalNumber *minimumValue = nil;
    if (!minimumValue) {
        minimumValue = [[IAEConcept maxCentinelConceptValue] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    }
    
    return minimumValue;
}

#pragma mark - Compare

- (NSComparisonResult)compare:(IAEConcept *)concept
{
    return [[NSNumber numberWithDouble:self.date] compare:[NSNumber numberWithDouble:concept.date]];
}

#pragma mark - Amount

- (NSDecimalNumber *)amountWithSign
{
    NSDecimalNumber *retAmount = self.amount;
    if ([self.category isExpenseCategory]) {
        retAmount = [retAmount decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]];
    }
    
    return retAmount;
}

#pragma mark - Assign

- (BOOL)canAssignSignedValue:(NSDecimalNumber *)signedValue
{
    BOOL retCanAssign = NO;
    
    NSComparisonResult compareToZero = [signedValue compare:[NSDecimalNumber zero]];
    if (compareToZero == NSOrderedAscending) {
        retCanAssign = self.category.categoryType == ExpenseCategory;
    } else if (compareToZero == NSOrderedDescending) {
        retCanAssign = self.category.categoryType == IncomeCategory;
    }
    
    return retCanAssign;
}

#pragma mark - Check amounts

- (BOOL)canAddAmount:(NSNumber *)amount
{
    NSDecimalNumber *decimalNumberOfAmount = [NSDecimalNumber decimalNumberWithString:amount.stringValue];
    NSDecimalNumber *actualAmount = [self amountWithSign];
    NSDecimalNumber *newActualAmount = [actualAmount decimalNumberByAdding:decimalNumberOfAmount];
    BOOL can = [self canAssignSignedValue:newActualAmount];
    if (can) {
        can = [newActualAmount compare:[IAEConcept maxCentinelConceptValue]] == NSOrderedAscending;
        if (can) {
            can = [newActualAmount compare:[IAEConcept minCentinelConceptValue]] == NSOrderedDescending;
        }
    }
    
    return can;
}

@end
