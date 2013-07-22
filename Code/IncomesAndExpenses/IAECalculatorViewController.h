//
//  IAECalculatorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IAECalculatorViewControllerDelegate;

@interface IAECalculatorViewController : UIViewController

@property(nonatomic, weak)id<IAECalculatorViewControllerDelegate> delegate;
@property(nonatomic, readonly)CGFloat sizeHeightOffsetWhenShowed;

- (IBAction)incomeButtonPressed:(id)sender;
- (IBAction)expenseButtonPressed:(id)sender;

- (BOOL)isInHideMode;
- (BOOL)isInVisibleMode;
- (BOOL)isInIncomeMode;
- (BOOL)isInExpenseMode;

@end
