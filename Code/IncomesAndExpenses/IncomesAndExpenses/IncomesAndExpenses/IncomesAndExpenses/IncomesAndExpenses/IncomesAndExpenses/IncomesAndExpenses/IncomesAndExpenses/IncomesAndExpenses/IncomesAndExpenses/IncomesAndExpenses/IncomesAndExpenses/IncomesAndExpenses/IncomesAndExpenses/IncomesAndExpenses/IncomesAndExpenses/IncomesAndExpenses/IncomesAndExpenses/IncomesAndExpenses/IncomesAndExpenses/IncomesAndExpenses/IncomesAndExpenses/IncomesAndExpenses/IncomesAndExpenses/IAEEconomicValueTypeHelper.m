//
//  IAEEconomicValueTypeHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEconomicValueTypeHelper.h"

@implementation IAEEconomicValueTypeHelper

+ (EconomicValueType)economicValueTypeOfEconomicValue:(NSDecimalNumber *)economicValue
{
    NSComparisonResult balanceValueType = [economicValue compare:[NSDecimalNumber zero]];
    
    EconomicValueType economicType = ECONOMIC_ZERO_VALUE;
    if (balanceValueType == NSOrderedAscending) {
        economicType = ECONOMIC_EXPENSE_VALUE;
    } else if (balanceValueType == NSOrderedDescending) {
        economicType = ECONOMIC_INCOME_VALUE;
    }
    
    return economicType;
}

@end
