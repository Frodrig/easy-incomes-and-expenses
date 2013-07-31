//
//  IAEYearsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEAdjustConceptAmountViewControllerDelegate.h"
#import "IAECategorySelectorViewControllerDelegate.h"
#import "IAECategoryEditorViewControllerDelegate.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEContextViewDataSource.h"
#import "IAEDayCalendarSelectorViewControllerDelegate.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAETextRawSelectorMenuViewDelegate.h"
#import "IAEReportAreaViewDelegate.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"

@interface IAEEasyIncomesAndExpensesViewController : UIViewController<UIPopoverControllerDelegate,
                                                                      UIScrollViewDelegate,
                                                                      UICollectionViewDelegate,
                                                                      IAEAdjustConceptAmountViewControllerDelegate,
                                                                      IAECategorySelectorViewControllerDelegate,
                                                                      IAECategoryEditorViewControllerDelegate,
                                                                      IAEYearSelectorViewControllerDelegate,
                                                                      IAEContextViewDataSource,
                                                                      IAEDayCalendarSelectorViewControllerDelegate,
                                                                      IAECalculatorViewControllerDelegate,
                                                                      IAEReportAreaViewDelegate,
                                                                      IAETextRawSelectorMenuViewDelegate,
                                                                      IAEEasyIncomesAndExpensesViewControllerQuery>

- (IBAction)categoriesButtonPressed:(id)sender;
- (IBAction)yearsButtonPressed:(id)sender;

- (void)reloadAllWithAnimation:(BOOL)animation;

@end
