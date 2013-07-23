//
//  IAECalculatorViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECalculatorViewController;
@class IAEConcept;

@protocol IAECalculatorViewControllerDelegate <NSObject>

- (void)showButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;
- (void)hideButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept;

@end
