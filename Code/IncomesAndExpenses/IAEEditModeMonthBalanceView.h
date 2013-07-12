//
//  IAEEditModeMonthBalanceView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAEEditModeMonthBalanceViewDataSource;

@interface IAEEditModeMonthBalanceView : UIView

@property(nonatomic, weak)id<IAEEditModeMonthBalanceViewDataSource> dataSource;

- (id)initWithFrame:(CGRect)frame andMonthIndex:(NSUInteger)monthIndex;

- (void)reloadDataWithAnimation:(BOOL)animation;

@end
