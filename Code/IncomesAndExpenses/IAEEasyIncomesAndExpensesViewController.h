//
//  IAEYearsViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 27/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAESelectorContextViewDelegate.h"
#import "IAESelectorContextViewDataSource.h"
#import "IAEAdjustConceptAmountViewControllerDelegate.h"
#import "IAECategorySelectorViewControllerDelegate.h"
#import "IAECategoryEditorViewControllerDelegate.h"
#import "IAEYearSelectorViewControllerDelegate.h"
#import "IAEContextViewDataSource.h"
#import "IAEDayCalendarSelectorViewControllerDelegate.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAETextRawSelectorMenuViewDelegate.h"
#import "IAEStrokeAnimatableViewDelegate.h"
#import "IAEReportAreaViewDelegate.h"
#import "IAEAdjustConceptAmountViewControllerDataSource.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "IAEFavoriteConceptsViewControllerDelegate.h"
#import "IAEMonthSelectorViewControllerDelegate.h"
#import "IAEContextMenuActionSheetViewControllerDelegate.h"
#import "IAEEasyIncomesAndExpensesQueryDataSource.h"

@protocol IAEEasyIncomesAndExpensesViewControllerDelegate;

@interface IAEEasyIncomesAndExpensesViewController : UIViewController<UIPopoverControllerDelegate,
                                                                      IAESelectorContextViewDelegate,
                                                                      IAESelectorContextViewDataSource,
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

                                                                      MFMailComposeViewControllerDelegate,
                                                                      UIAlertViewDelegate,
                                                                      IAEFavoriteConceptsViewControllerDelegate,
                                                                      IAEMonthSelectorViewControllerDelegate,
                                                                      IAEContextMenuActionSheetViewControllerDelegate,
                                                                      IAEEasyIncomesAndExpensesQueryDataSource>

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerDelegate> delegate;
@property (nonatomic) BOOL helpModeActivated;

- (void)categoriesButtonPressed:(id)sender;
- (void)yearsButtonPressed:(id)sender;
- (void)settingsOptionPressed:(id)sender;

- (void)reloadAllWithAnimation:(BOOL)animation;

- (void)resetToLaunchState;

@end
