//
//  IAEEasyIncomesAndExpensesViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 13/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEEasyIncomesAndExpensesViewController;

@protocol IAEEasyIncomesAndExpensesViewControllerDelegate <NSObject>

- (void)lauchCompleteInEasyIncomesAndExpensesViewController:(IAEEasyIncomesAndExpensesViewController *)easyIncomesAndExpensesViewController;

@end
