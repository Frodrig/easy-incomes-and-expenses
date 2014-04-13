//
//  IAEMonthSelectorViewControllerDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthDefs.h"

@class IAEMonthSelectorViewController;

@protocol IAEMonthSelectorViewControllerDelegate <NSObject>

- (void)monthSelectorViewController:(IAEMonthSelectorViewController *)monthSelectorViewController didSelectMonth:(MonthType)month;

@end
