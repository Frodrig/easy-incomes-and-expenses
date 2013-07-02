//
//  IAEConceptsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 04/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEInputConceptsDelegate.h"
#import "IAEInputConceptsDataSource.h"
#import "IAEAmountStepperViewControllerDelegate.h"

@class IAEYear;
@class IAEMonth;

@interface IAEConceptsViewController : UIViewController<UITableViewDataSource,
                                                        UITableViewDelegate,
                                                        UIScrollViewDelegate,
                                                        IAEInputConceptsDelegate,
                                                        IAEInputConceptsDataSource,
                                                        IAEAmountStepperViewControllerDelegate,
                                                        UIPopoverControllerDelegate>

@property (nonatomic, weak, readonly) IAEYear *selectedYear;

- (id)initStartingInMonthIndex:(NSInteger)monthIndex;

- (IAEYear *)actualDateStateYear;
- (IAEMonth *)actualDateStateMonth;

- (BOOL)isEditModeActive;

@end
