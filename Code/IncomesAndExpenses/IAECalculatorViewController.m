//
//  IAECalculatorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECalculatorViewController.h"
#import "IAEDragPanelCalculatorView.h"
#import "IAECalculatorViewControllerDelegate.h"

@interface IAECalculatorViewController ()

typedef NS_ENUM(NSUInteger, CalculatorMode) {
    CM_HIDE,
    CM_INCOME,
    CM_EXPENSE
};

@property (weak, nonatomic) IBOutlet IAEDragPanelCalculatorView *dragPanel;
@property(nonatomic)CalculatorMode mode;

@end

@implementation IAECalculatorViewController

static CGFloat animationDurationShowHideAction = 0.25;
static CGFloat marginHeightOffsetWhenShowed = 10;

- (CGFloat)sizeHeightOffsetWhenShowed
{
    return [self calculeAbsoluteOffsetDisplacementValue] + marginHeightOffsetWhenShowed;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _mode = CM_HIDE;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - State questions

- (BOOL)isInHideMode
{
    return self.mode == CM_HIDE;
}

- (BOOL)isInVisibleMode
{
    return ![self isInHideMode];
}

- (BOOL)isInIncomeMode
{
    return self.mode == CM_INCOME;
}

- (BOOL)isInExpenseMode
{
    return self.mode == CM_EXPENSE;
}

#pragma mark - Drag Panel View Events

- (IBAction)incomeButtonPressed:(id)sender
{
    if ([self isInHideMode]) {
        [self.delegate showButtonPressedOnCalculatorViewController:self];
        [self show];
        self.mode = CM_INCOME;
    } else if ([self isInIncomeMode]) {
        [self.delegate hideButtonPressedOnCalculatorViewController:self];
        [self hide];
        self.mode = CM_HIDE;
    } else if ([self isInExpenseMode]) {
        self.mode = CM_INCOME;
    }
}

- (IBAction)expenseButtonPressed:(id)sender
{
    if ([self isInHideMode]) {
        [self.delegate showButtonPressedOnCalculatorViewController:self];
        [self show];
        self.mode = CM_EXPENSE;
    } else if ([self isInExpenseMode]) {
        [self.delegate hideButtonPressedOnCalculatorViewController:self];
        [self hide];
        self.mode = CM_HIDE;
    } else if ([self isInIncomeMode]) {
        self.mode = CM_EXPENSE;
    }
}

#pragma mark - Hide / Show actions

- (void)show
{
    [self updateVisibilityWithOffset:-[self calculeAbsoluteOffsetDisplacementValue] usingAnimation:YES];
}

- (void)hide
{
    [self updateVisibilityWithOffset:[self calculeAbsoluteOffsetDisplacementValue] usingAnimation:YES];
}

- (CGFloat)calculeAbsoluteOffsetDisplacementValue
{
    return self.view.bounds.size.height - self.dragPanel.bounds.size.height;
}

- (void)updateVisibilityWithOffset:(CGFloat)offset usingAnimation:(BOOL)animation
{
    [UIView animateWithDuration:animation ? animationDurationShowHideAction : 0.0 animations:^{
        self.view.frame = CGRectMake(self.view.frame.origin.x,
                                     self.view.frame.origin.y + offset,
                                     self.view.frame.size.width,
                                     self.view.frame.size.height);
    }];
}

@end
