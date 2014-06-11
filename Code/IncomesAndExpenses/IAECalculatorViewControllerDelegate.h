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
- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController hideButtonWasPressedWithAnimation:(BOOL)animation;

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcept:(IAEConcept *)concept;
- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didCreateNewConcepts:(NSArray *)concepts;

- (void)calculatorViewController:(IAECalculatorViewController *)calculatorViewController didRemoveFavoriteConceptWithCategory:(NSString *)category andValue:(NSString *)value;

- (void)showFavoritesButtonWasPressedOnCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;

@end
