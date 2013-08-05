//
//  IAEHelperCalculatorDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAECalculatorViewControllerDataSource.h"

@protocol IAEEasyIncomesAndExpensesViewControllerQuery;

@interface IAEHelperCalculatorDataSource : NSObject<IAECalculatorViewControllerDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query;

@end
