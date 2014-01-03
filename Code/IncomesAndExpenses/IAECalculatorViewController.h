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
#import "IAEDisplayPanelCalculatorViewDelegate.h"
#import "IAEDisplayPanelCalculatorViewDataSource.h"
#import "IAEFavoriteConceptsViewControllerDelegate.h"

@class IAEDragPanelCalculatorView;
@protocol IAECalculatorViewControllerDelegate;
@protocol IAECalculatorViewControllerDataSource;

@interface IAECalculatorViewController : UIViewController<UIPopoverControllerDelegate,
                                                          IAECategorySelectorViewControllerDelegate,
                                                          IAEDayCalendarSelectorViewControllerDelegate,
                                                          IAECategoryEditorViewControllerDelegate,
                                                          IAEDisplayPanelCalculatorViewDelegate,
                                                          IAEDisplayPanelCalculatorViewDataSource,
                                                          IAEFavoriteConceptsViewControllerDelegate>

@property (nonatomic, weak) id<IAECalculatorViewControllerDelegate> delegate;
@property (nonatomic, weak) id<IAECalculatorViewControllerDataSource> dataSource;

@property (weak, nonatomic) IBOutlet IAEDragPanelCalculatorView *dragPanel;
@property (nonatomic, readonly) CGFloat sizeHeightOffsetWhenShowed;
@property (nonatomic, readonly) CGFloat sizeHeightOfDragPanel;
@property (nonatomic, readonly, getter = isInDisableMode) BOOL disableMode;

- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer;
- (void)removePanGestureRecognizer;

- (void)calculeDragLimits;

- (void)beginDragTranslation;
- (void)endDragTranslation;
- (void)doDragTranslation:(CGFloat)translation;

- (IBAction)incomeButtonPressed:(id)sender;
- (IBAction)expenseButtonPressed:(id)sender;

- (void)hide;

- (IBAction)categoryButtonPressed:(UIButton *)button;
- (IBAction)dayButtonPressed:(UIButton *)button;
- (IBAction)keyboardNumberPressed:(UIButton *)button;
- (IBAction)keyboardDeletePressed:(UIButton *)button;
- (IBAction)keyboardDecimalPressed:(UIButton *)button;
- (IBAction)keyboardEnterPressed:(UIButton *)button;

- (BOOL)isInHideMode;
- (BOOL)isInVisibleMode;
- (BOOL)isInIncomeMode;
- (BOOL)isInExpenseMode;
- (BOOL)isOpen;
- (BOOL)isClosed;

- (void)disable;
- (void)enable;
- (BOOL)isDisabeOptionAvailable;

- (BOOL)isAnyTranslationActive;

@end
