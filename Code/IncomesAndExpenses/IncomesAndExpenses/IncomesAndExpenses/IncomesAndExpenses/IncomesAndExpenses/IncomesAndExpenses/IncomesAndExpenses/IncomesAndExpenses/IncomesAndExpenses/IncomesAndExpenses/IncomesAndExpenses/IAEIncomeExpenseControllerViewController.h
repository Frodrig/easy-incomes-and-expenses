//
//  IAEIncomeExpenseControllerViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEYearsConfigViewControllerDelegate.h"
#import "IAENewYearDatePickerDelegate.h"
#import "IAEInputConceptsDelegate.h"

@class IAEMonth;

@interface IAEIncomeExpenseControllerViewController : UIViewController<UIScrollViewDelegate, UIPopoverControllerDelegate, IAEYearsConfigViewControllerDelegate, IAEInputConceptsDelegate, IAENewYearDatePickerDelegate>

- (BOOL)inputModeActive;
- (IAEYear *)actualDateStateYear;
- (IAEMonth *)actualDateStateMonth;

- (void)unloadConceptControllersGoingToBackground;
- (void)loadConceptControllersToRestoreFromBackgroundWithActualLoadedYearAndMonth:(NSInteger)monthIndex;

@end
