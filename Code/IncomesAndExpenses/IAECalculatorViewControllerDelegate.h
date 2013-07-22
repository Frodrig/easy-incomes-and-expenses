//
//  IAECalculatorViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECalculatorViewController;

@protocol IAECalculatorViewControllerDelegate <NSObject>

- (void)showButtonPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;
- (void)hideButtonPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;

@end
