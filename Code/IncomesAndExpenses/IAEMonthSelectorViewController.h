//
//  IAEMonthSelectorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 12/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEMonthSelectorViewControllerDelegate.h"
#import "MonthDefs.h"

@interface IAEMonthSelectorViewController : UIViewController

@property (nonatomic, weak) id<IAEMonthSelectorViewControllerDelegate> delegate;

- (instancetype)initWithActualMonth:(MonthType)actualMonth andInvalidInteractionMonths:(NSSet *)invalidInteractionMonths;

@end
