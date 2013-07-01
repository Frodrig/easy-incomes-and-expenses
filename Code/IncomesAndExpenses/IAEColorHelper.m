//
//  IAEColorHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEColorHelper.h"

@implementation IAEColorHelper

+ (UIColor *)colorForEconomicValueType:(EconomicValueType)economicValueType
{
    UIColor *retColor = nil;
    
    switch (economicValueType) {
        case ECONOMIC_INCOME_VALUE:
            return [UIColor colorWithRed:120.0/255.0 green:191.0/255.0 blue:175.0/255.0 alpha:1.0];
            break;
            
        case ECONOMIC_EXPENSE_VALUE:
            return [UIColor colorWithRed:255.0/255.0 green:154.0/255.0 blue:85.0/255.0 alpha:1.0];
            break;
            
        default:
            NSAssert(economicValueType == ECONOMIC_INVALID_VALUE, @"Valor economico invalido");
            return [UIColor colorWithWhite:0 alpha:0.25];
            break;
    }
    
    return retColor;
}

+ (UIColor *)colorForEconomicIncomeValue
{
    return [self colorForEconomicValueType:ECONOMIC_INCOME_VALUE];
}

+ (UIColor *)colorForEconomicExpenseValue
{
    return [self colorForEconomicValueType:ECONOMIC_EXPENSE_VALUE];
}

+ (UIColor *)colorForEconomicInvalidValue
{
    return [self colorForEconomicValueType:ECONOMIC_INVALID_VALUE];
}

@end
