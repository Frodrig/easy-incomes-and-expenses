//
//  IAEDisplayPanelCalculatorViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 23/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEDisplayPanelCalculatorView;

@protocol IAEDisplayPanelCalculatorViewDelegate <NSObject>

- (void)amountLabelWasCleanInDisplayPanelCalculatorView:(IAEDisplayPanelCalculatorView *)displayPanelCalculatorView;

@end
