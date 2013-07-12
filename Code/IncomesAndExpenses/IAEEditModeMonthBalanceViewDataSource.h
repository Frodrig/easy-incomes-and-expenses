//
//  IAEEditModeMonthBalanceViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEEditModeMonthBalanceView;

@protocol IAEEditModeMonthBalanceViewDataSource <NSObject>

- (NSString *)editModeMonthBalanceView:(IAEEditModeMonthBalanceView *)editModeMonthBalanceView
            monthNameForMonthWithIndex:(NSUInteger)monthIndex;

- (NSDecimalNumber *)editModeMonthBalanceView:(IAEEditModeMonthBalanceView *)editModeMonthBalanceView
                monthBalanceForMonthWithIndex:(NSUInteger)monthIndex;

@end
