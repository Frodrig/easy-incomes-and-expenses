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

+ (UIColor *)colorForEconomicIncomeValue;
+ (UIColor *)colorForEconomicExpenseValue;
+ (UIColor *)colorForEconomicZeroValue;

@end
