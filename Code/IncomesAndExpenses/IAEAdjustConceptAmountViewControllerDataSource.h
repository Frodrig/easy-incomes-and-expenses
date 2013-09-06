//
//  IAEAdjustConceptAmountViewControllerDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEAdjustConceptAmountViewController;

@protocol IAEAdjustConceptAmountViewControllerDataSource <NSObject>

- (BOOL)canAdjustConceptAmountViewController:(IAEAdjustConceptAmountViewController *)adjustConceptViewController addAmount:(NSNumber *)amount;

@end
