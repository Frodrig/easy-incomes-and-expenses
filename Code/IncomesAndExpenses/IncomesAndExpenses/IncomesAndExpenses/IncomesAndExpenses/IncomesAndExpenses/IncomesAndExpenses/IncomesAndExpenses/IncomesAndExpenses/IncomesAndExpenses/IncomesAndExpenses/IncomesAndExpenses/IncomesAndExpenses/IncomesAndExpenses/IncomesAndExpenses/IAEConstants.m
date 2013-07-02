//
//  IAEConstants.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEConstants.h"

@implementation IAEConstants

+ (UIColor *)incomeValueColor
{
    static UIColor *incomeValue = nil;
    if (nil == incomeValue)
        incomeValue = [UIColor colorWithRed:0.0 green:190.0/255.0 blue:118.0/255.0 alpha:1.0];
    
    return incomeValue;
}

+ (UIColor *)expenseValueColor;
{
    static UIColor *expenseValue = nil;
    if (nil == expenseValue)
        //expenseValue = [UIColor colorWithRed:254.0/255.0 green:100.0/255.0 blue:0.0/255.0 alpha:1.0];
        expenseValue = [UIColor colorWithRed:200.0/255.0 green:140.0/255.0 blue:0.0/255.0 alpha:1.0];
    return expenseValue;
}

+ (UIColor *)zeroValueColor
{
    static UIColor *zeroValueColor = nil;
    if (nil == zeroValueColor)
        zeroValueColor = [UIColor colorWithRed:241.0/255.0 green:241.0/255.0 blue:223.0/255.0 alpha:1.0];
    
    return zeroValueColor;
}

+ (UIColor *)sectionsTablesBackgroundColor
{
    static UIColor *backgroundColor = nil;
    if (nil == backgroundColor)
        backgroundColor = [UIColor colorWithRed:0.15 green:0.15 blue:0.15 alpha:1.0];
    
    return backgroundColor;
}

+ (UIColor *)sectionsSettingsBackgroundColor
{
    static UIColor *backgroundColor = nil;
    if (nil == backgroundColor)
        backgroundColor = [UIColor colorWithRed:0.11 green:0.11 blue:0.11 alpha:1.0];
    
    return backgroundColor;
}
+ (NSDecimalNumber *)maxDecimalNumberAllowed {
    static NSDecimalNumber *maxDecimal = nil;
    if (maxDecimal == nil) {
        maxDecimal = [NSDecimalNumber decimalNumberWithString:@"9999999999999" locale:[NSLocale currentLocale]];
    }
    return maxDecimal;
}


@end
