//
//  IAEInputConceptsDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CABasicAnimation;

@protocol IAEInputConceptsDelegate <NSObject>

- (void)inputChangePosition:(CGFloat) offsetY;

- (void)inputShowed;
- (void)inputHidden;

- (void)inputAnimationShowedWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed;
- (void)inputAnimationHiddenWithOffset:(CGFloat)offsetY andDuration:(CGFloat)duration andSpeed:(CGFloat)speed;

- (void)inputChangeCategoryModeToIncome;
- (void)inputChangeCategoryModeToExpense;

@end
