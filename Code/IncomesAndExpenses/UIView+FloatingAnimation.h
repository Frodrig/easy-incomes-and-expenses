//
//  UIView+FloatingAnimation.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FloatingAnimation)<CAAnimationDelegate>

- (void)startFloatingAnimation;
- (void)endCurrentFloatingAnimation;
- (BOOL)floatingAnimationActive;

@end
