//
//  IAENewYearDatePickerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 13/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IAENewYearDatePickerDelegate <NSObject>

- (void)newYearDatePickerSelectionCancelled;
- (void)newYearDatePickerSelectionDoneWithYear:(NSUInteger)year;

@end
