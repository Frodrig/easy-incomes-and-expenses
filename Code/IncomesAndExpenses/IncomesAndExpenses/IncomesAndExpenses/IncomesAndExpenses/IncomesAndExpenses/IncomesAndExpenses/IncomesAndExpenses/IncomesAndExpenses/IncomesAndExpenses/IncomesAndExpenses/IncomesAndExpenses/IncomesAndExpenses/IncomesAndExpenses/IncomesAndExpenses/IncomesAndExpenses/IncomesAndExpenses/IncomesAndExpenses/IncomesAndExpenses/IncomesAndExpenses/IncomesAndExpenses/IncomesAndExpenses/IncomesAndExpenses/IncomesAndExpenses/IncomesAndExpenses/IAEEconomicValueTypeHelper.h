//
//  IAEEconomicValueTypeHelper.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEValueDefs.h"

@interface IAEEconomicValueTypeHelper : NSObject

+ (EconomicValueType)economicValueTypeOfEconomicValue:(NSDecimalNumber *)economicValue;

@end
