//
//  IAEEconomicValueTypeHelper.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEValueDefs.h"
#import "CategoryDefs.h"

@interface IAEEconomicValueTypeHelper : NSObject

+ (EconomicValueType)economicValueTypeFromEconomicValue:(NSDecimalNumber *)economicValue;
+ (EconomicValueType)economicValueTypeFromCategoryType:(CategoryType)categoryType;

@end
