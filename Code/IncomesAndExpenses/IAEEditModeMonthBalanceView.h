//
//  IAEEditModeMonthBalanceView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEEditModeMonthBalanceView : UIView

@property(nonatomic, weak) UILabel *monthBalanceLabel;

- (id)initWithFrame:(CGRect)frame andMonthIndex:(NSUInteger)monthIndex;

@end
