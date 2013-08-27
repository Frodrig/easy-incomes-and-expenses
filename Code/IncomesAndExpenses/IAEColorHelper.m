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
    return [self colorForEconomicValueType:economicValueType withAlpha:1.0];
}

+ (UIColor *)colorForEconomicValueType:(EconomicValueType)economicValueType withAlpha:(CGFloat)alpha
{
    UIColor *retColor = nil;
    
    switch (economicValueType) {
        case ECONOMIC_INCOME_VALUE:
            return [UIColor colorWithRed:120.0/255.0 green:191.0/255.0 blue:175.0/255.0 alpha:alpha];
            break;
            
        case ECONOMIC_EXPENSE_VALUE:
            return [UIColor colorWithRed:255.0/255.0 green:154.0/255.0 blue:85.0/255.0 alpha:alpha];
            break;
            
        default:
            NSAssert(economicValueType == ECONOMIC_ZERO_VALUE, @"");
            return [UIColor colorWithWhite:0.55 alpha:alpha];
            break;
    }
    
    return retColor;
}

+ (UIColor *)colorForEconomicIncomeValue
{
    return [self colorForEconomicIncomeValueWithAlpha:1.0];
}

+ (UIColor *)colorForEconomicExpenseValue
{
    return [self colorForEconomicExpenseValueWithAlpha:1.0];
}

+ (UIColor *)colorForEconomicZeroValue
{
    return [self colorForEconomicZeroValueWithAlpha:1.0];
}

+ (UIColor *)colorForEconomicIncomeValueWithAlpha:(CGFloat)alha
{
    return [self colorForEconomicValueType:ECONOMIC_INCOME_VALUE withAlpha:alha];
}

+ (UIColor *)colorForEconomicExpenseValueWithAlpha:(CGFloat)alpha
{
    return [self colorForEconomicValueType:ECONOMIC_EXPENSE_VALUE withAlpha:alpha];
}

+ (UIColor *)colorForEconomicZeroValueWithAlpha:(CGFloat)alpha
{
    return [self colorForEconomicValueType:ECONOMIC_ZERO_VALUE withAlpha:alpha];
}

@end
