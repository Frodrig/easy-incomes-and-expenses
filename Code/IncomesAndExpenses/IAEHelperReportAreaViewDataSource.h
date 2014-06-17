//
//  IAEHelperReportAreaViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEReportAreaViewDataSource.h"

@class IAEEasyIncomesAndExpensesQuery;

@interface IAEHelperReportAreaViewDataSource : NSObject<IAEReportAreaViewDataSource>

- (id)initWithEasyIncomesViewControllerQuery:(IAEEasyIncomesAndExpensesQuery *)query;

@end
