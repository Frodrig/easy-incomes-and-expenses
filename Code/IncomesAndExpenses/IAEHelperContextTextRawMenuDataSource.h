//
//  IAEHelperContextTextRawMenuDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAETextRawSelectorMenuViewDataSource.h"

@class IAEEasyIncomesAndExpensesQuery;

@interface IAEHelperContextTextRawMenuDataSource : NSObject<IAETextRawSelectorMenuViewDataSource>

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(IAEEasyIncomesAndExpensesQuery *)query;

@end
