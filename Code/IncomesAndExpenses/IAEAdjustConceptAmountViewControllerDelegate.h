//
//  IAEAdjustConceptAmountViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEAdjustConceptAmountViewController;

@protocol IAEAdjustConceptAmountViewControllerDelegate <NSObject>

- (void)adjustConceptsAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptsAmountViewController
          didPressedAdjustButtonWithAmount:(NSNumber *)amount;


@end
