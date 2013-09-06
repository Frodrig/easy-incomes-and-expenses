//
//  IAEYearsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAESelectorContextViewDelegate.h"
#import "IAEAdjustConceptAmountViewControllerDelegate.h"
#import "IAECategorySelectorViewControllerDelegate.h"
#import "IAECategoryEditorViewControllerDelegate.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEContextViewDataSource.h"
#import "IAEDayCalendarSelectorViewControllerDelegate.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAETextRawSelectorMenuViewDelegate.h"
#import "IAEStrokeAnimatableViewDelegate.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"
#import "IAEReportAreaViewDelegate.h"
#import "IAEAdjustConceptAmountViewControllerDataSource.h"

@interface IAEEasyIncomesAndExpensesViewController : UIViewController<UIPopoverControllerDelegate,
                                                                      IAESelectorContextViewDelegate,
                                                                      UICollectionViewDelegate,
                                                                      IAEAdjustConceptAmountViewControllerDelegate,
                                                                      IAECategorySelectorViewControllerDelegate,
                                                                      IAECategoryEditorViewControllerDelegate,
                                                                      IAEYearSelectorViewControllerDelegate,
                                                                      IAEContextViewDataSource,
                                                                      IAEDayCalendarSelectorViewControllerDelegate,
                                                                      IAECalculatorViewControllerDelegate,
                                                                      IAETextRawSelectorMenuViewDelegate,
                                                                      IAEStrokeAnimatableViewDelegate,
                                                                      IAEReportAreaViewDelegate,
                                                                      IAEAdjustConceptAmountViewControllerDataSource,
                                                                      IAEEasyIncomesAndExpensesViewControllerQuery>

- (void)categoriesButtonPressed:(id)sender;
- (void)yearsButtonPressed:(id)sender;
- (void)settingsOptionPressed:(id)sender;

- (void)reloadAllWithAnimation:(BOOL)animation;

@end
