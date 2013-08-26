//
//  IAEColorHelper.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEValueDefs.h"

@interface IAEColorHelper : NSObject

+ (UIColor *)colorForEconomicValueType:(EconomicValueType)economicValueType;
+ (UIColor *)colorForEconomicValueType:(EconomicValueType)economicValueType withAlpha:(CGFloat)alpha;

+ (UIColor *)colorForEconomicIncomeValue;
+ (UIColor *)colorForEconomicExpenseValue;
+ (UIColor *)colorForEconomicZeroValue;

+ (UIColor *)colorForEconomicIncomeValueWithAlpha:(CGFloat)alha;
+ (UIColor *)colorForEconomicExpenseValueWithAlpha:(CGFloat)alpha;
+ (UIColor *)colorForEconomicZeroValueWithAlpha:(CGFloat)alpha;

@end
