//
//  IAEHelperCalculatorDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAECalculatorViewControllerDataSource.h"

@class IAEEasyIncomesAndExpensesQuery;

@interface IAEHelperCalculatorDataSource : NSObject<IAECalculatorViewControllerDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(IAEEasyIncomesAndExpensesQuery *)query;

@end
