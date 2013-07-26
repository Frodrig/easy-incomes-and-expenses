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
#import "IAECalculatorViewControllerDataSource.h"
#import "IAETextRawSelectorMenuViewDataSource.h"
#import "IAETextRawSelectorMenuViewDelegate.h"

@interface IAEEasyIncomesAndExpensesViewController : UIViewController<UIPopoverControllerDelegate,
                                                                      UIScrollViewDelegate,
                                                                      UICollectionViewDataSource,
                                                                      UICollectionViewDelegate,
                                                                      IAEAdjustConceptAmountViewControllerDelegate,
                                                                      IAECategorySelectorViewControllerDelegate,
                                                                      IAECategoryEditorViewControllerDelegate,
                                                                      IAEYearSelectorViewControllerDelegate,
                                                                      IAEContextViewDataSource,
                                                                      IAEDayCalendarSelectorViewControllerDelegate,
                                                                      IAECalculatorViewControllerDelegate,
                                                                      IAECalculatorViewControllerDataSource,
                                                                      IAETextRawSelectorMenuViewDataSource,
IAETextRawSelectorMenuViewDelegate>

- (IBAction)categoriesButtonPressed:(id)sender;
- (IBAction)yearsButtonPressed:(id)sender;

- (void)reloadAllWithAnimation:(BOOL)animation;

@end
