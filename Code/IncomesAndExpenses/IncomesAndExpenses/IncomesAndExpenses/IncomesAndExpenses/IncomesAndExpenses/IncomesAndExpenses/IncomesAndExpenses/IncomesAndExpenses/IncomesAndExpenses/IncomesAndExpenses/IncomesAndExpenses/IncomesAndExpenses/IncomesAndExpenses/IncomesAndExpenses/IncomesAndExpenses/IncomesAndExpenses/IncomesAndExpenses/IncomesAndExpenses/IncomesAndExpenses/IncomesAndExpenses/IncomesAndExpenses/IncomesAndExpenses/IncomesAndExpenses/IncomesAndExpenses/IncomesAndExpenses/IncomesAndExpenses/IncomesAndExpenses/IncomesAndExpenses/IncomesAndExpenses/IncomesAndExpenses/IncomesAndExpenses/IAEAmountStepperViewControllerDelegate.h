//
//  IAEAmountStepperViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 25/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAEAmountStepperViewControllerDelegate <NSObject>

- (void)onMinusButtonPressed:(id)amountStepperViewController withAmount:(NSNumber *)value;
- (void)onPlusButtonPressed:(id)amountStepperViewController withAmount:(NSNumber *)value;

@end
