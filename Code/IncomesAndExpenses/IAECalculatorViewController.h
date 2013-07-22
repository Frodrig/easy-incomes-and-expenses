//
//  IAECalculatorViewController.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAECategorySelectorViewControllerDelegate.h"
#import "IAEDayCalendarSelectorViewControllerDelegate.h"
#import "IAECategoryEditorViewControllerDelegate.h"

@protocol IAECalculatorViewControllerDelegate;
@protocol IAECalculatorViewControllerDataSource;

@interface IAECalculatorViewController : UIViewController<UIPopoverControllerDelegate,
                                                          IAECategorySelectorViewControllerDelegate,
                                                          IAEDayCalendarSelectorViewControllerDelegate,
                                                          IAECategoryEditorViewControllerDelegate>

@property (nonatomic, weak) id<IAECalculatorViewControllerDelegate> delegate;
@property (nonatomic, weak) id<IAECalculatorViewControllerDataSource> dataSource;

@property (nonatomic, readonly) CGFloat sizeHeightOffsetWhenShowed;

- (IBAction)incomeButtonPressed:(id)sender;
- (IBAction)expenseButtonPressed:(id)sender;

- (IBAction)categoryButtonPressed:(UIButton *)button;
- (IBAction)dayButtonPressed:(UIButton *)button;

- (BOOL)isInHideMode;
- (BOOL)isInVisibleMode;
- (BOOL)isInIncomeMode;
- (BOOL)isInExpenseMode;

@end
