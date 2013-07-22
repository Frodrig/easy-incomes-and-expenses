//
//  IAEDisplayPanelView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IAEDisplayPanelCalculatorView : UIView

- (void)setCategoryName:(NSString *)categoryName;
- (void)setDay:(NSUInteger)day;
- (void)setAmount:(NSDecimalNumber *)amount;

- (void)showDayButton;
- (void)hideDayButton;
- (BOOL)isDayButtonVisible;

@end
