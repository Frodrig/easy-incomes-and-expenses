//
//  IAEDisplayPanelView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEStrokeAnimatableViewDelegate.h"

@protocol IAEDisplayPanelCalculatorViewDelegate;
@protocol IAEDisplayPanelCalculatorViewDataSource;

@interface IAEDisplayPanelCalculatorView : UIView<IAEStrokeAnimatableViewDelegate>

@property (nonatomic, weak) id<IAEDisplayPanelCalculatorViewDelegate> delegate;
@property (nonatomic, weak) id<IAEDisplayPanelCalculatorViewDataSource> dataSource;

- (void)setCategoryName:(NSString *)categoryName;
- (void)setDay:(NSUInteger)day withDayweekName:(NSString *)dayWeekName inMonthName:(NSString *)monthName ofYearName:(NSString *)yearName;
- (void)setMonthName:(NSString *)monthName ofYearName:(NSString *)yearName;
- (void)setAmountString:(NSString *)amount;
- (void)setDisplayWithIncomeColorUsingAnimation:(BOOL)animation;
- (void)setDisplayExpenseColorUsingAnimation:(BOOL)animation;

@end
