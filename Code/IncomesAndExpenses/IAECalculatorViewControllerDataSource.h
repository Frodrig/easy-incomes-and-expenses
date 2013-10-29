//
//  IAECalculatorViewControllerDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECalculatorViewController;
@class IAEOpenYear;
@class IAEMonth;

@protocol IAECalculatorViewControllerDataSource <NSObject>

- (IAEOpenYear *)yearForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;
- (IAEMonth *)monthForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController;

@end
