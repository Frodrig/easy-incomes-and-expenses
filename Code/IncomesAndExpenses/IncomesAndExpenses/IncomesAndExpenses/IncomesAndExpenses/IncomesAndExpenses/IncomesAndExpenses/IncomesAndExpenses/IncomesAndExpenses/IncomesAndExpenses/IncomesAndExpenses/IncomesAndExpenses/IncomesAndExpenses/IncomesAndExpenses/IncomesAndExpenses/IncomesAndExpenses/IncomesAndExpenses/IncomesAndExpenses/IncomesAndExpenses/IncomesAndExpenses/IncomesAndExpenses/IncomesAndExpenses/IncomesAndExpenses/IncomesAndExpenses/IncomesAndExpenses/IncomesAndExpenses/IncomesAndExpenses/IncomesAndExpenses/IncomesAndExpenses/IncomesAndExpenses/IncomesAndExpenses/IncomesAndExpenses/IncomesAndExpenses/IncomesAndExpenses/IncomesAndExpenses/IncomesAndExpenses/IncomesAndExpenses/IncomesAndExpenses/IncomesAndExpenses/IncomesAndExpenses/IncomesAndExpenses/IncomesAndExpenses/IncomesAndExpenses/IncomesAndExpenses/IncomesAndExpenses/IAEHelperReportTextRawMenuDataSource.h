//
//  IAEIAEHelperReportTextRawMenuDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAETextRawSelectorMenuViewDataSource.h"

@protocol IAEEasyIncomesAndExpensesViewControllerQuery;

@interface IAEHelperReportTextRawMenuDataSource : NSObject<IAETextRawSelectorMenuViewDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query;

@end
