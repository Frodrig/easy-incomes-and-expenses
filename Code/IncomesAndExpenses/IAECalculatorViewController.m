//
//  IAECalculatorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECalculatorViewController.h"
#import "IAEDragPanelCalculatorView.h"
#import "IAEDisplayPanelCalculatorView.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAECategorySelectorViewController.h"
#import "IAEDayCalendarSelectorViewController.h"

@interface IAECalculatorViewController ()

typedef NS_ENUM(NSUInteger, CalculatorMode) {
    CM_HIDE,
    CM_INCOME,
    CM_EXPENSE
};

@property (weak, nonatomic) IBOutlet IAEDragPanelCalculatorView *dragPanel;
@property (weak, nonatomic) IBOutlet IAEDisplayPanelCalculatorView *displayPanel;
@property (nonatomic) CalculatorMode mode;
@property (nonatomic, weak) IAECategory *actualCategory;
@property (nonatomic) NSUInteger actualDay;
@property (nonatomic, strong) UIPopoverController *popover;

@end

@implementation IAECalculatorViewController

static CGFloat animationDurationShowHideAction = 0.25;
static CGFloat marginHeightOffsetWhenShowed = 10;

static NSString * const userDefaultsDayModeActive = @"dayModeActive";
static NSString * const notificationDayModeOnName = @"dayModeToOn";
static NSString * const notificationDayModeOffName = @"dayModeToOff";

- (CGFloat)sizeHeightOffsetWhenShowed
{
    return [self calculeAbsoluteOffsetDisplacementValue] + marginHeightOffsetWhenShowed;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self initValues];
        [self initAsObserverOfNotificationCenter];
    }
    
    return self;
}

- (void)initValues
{
    _mode = CM_HIDE;    
}

- (void)initAsObserverOfNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOn:)
                                                 name:notificationDayModeOnName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOff:)
                                                 name:notificationDayModeOffName
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
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
    self.actualCategory = [[IAECategoryStore sharedCategoryStore] generalIncomeCategory];
    [self processDragPannelButtonPressedWithMode:CM_INCOME];
}

- (IBAction)expenseButtonPressed:(id)sender
{
    self.actualCategory = [[IAECategoryStore sharedCategoryStore] generalExpenseCategory];
    [self processDragPannelButtonPressedWithMode:CM_EXPENSE];
}

- (void)processDragPannelButtonPressedWithMode:(CalculatorMode)mode
{
    NSAssert(mode != CM_HIDE, @"");
    
    if ([self isInHideMode]) {
        [self showInMode:mode];
        [self configureDisplayPanelInShowMode];
    } else if ([self isDragPannelModeEqualToMode:mode]) {
        [self hide];
    } else {
        NSAssert(![self isDragPannelModeEqualToMode:mode], @"");
        self.mode = mode;
    }
}

- (void)configureDisplayPanelInShowMode
{
    NSAssert(![self isInHideMode], @"");
    
    [self configureDisplayPanelWithActualCategory];
    [self configureDisplayPanelWithActualDay];
}

- (void)configureDisplayPanelWithActualCategory
{
    [self.displayPanel setCategoryName:self.actualCategory.tag];
}

- (void)configureDisplayPanelWithActualDay
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsDayModeActive]) {
        [self.displayPanel showDayButton];
        [self.displayPanel setDay:self.actualDay];
    } else {
        [self.displayPanel hideDayButton];
    }
}

- (BOOL)isDragPannelModeEqualToMode:(CalculatorMode)mode
{
    return mode == self.mode;
}

- (void)showInMode:(CalculatorMode)mode;
{
    NSAssert(mode != CM_HIDE, @"");
    self.mode = mode;
    
    [self updateVisibilityWithOffset:-[self calculeAbsoluteOffsetDisplacementValue] usingAnimation:YES];
    
    [self.delegate showButtonPressedOnCalculatorViewController:self];
}

- (void)hide
{
    self.mode = CM_HIDE;
    [self updateVisibilityWithOffset:[self calculeAbsoluteOffsetDisplacementValue] usingAnimation:YES];

    [self.delegate hideButtonPressedOnCalculatorViewController:self];
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

#pragma mark - Display Panel Events

- (IBAction)categoryButtonPressed:(UIButton *)button
{
    [self launchPopoverForSelectCategoryFromRect:button.frame];
}

- (void)launchPopoverForSelectCategoryFromRect:(CGRect)rect
{
    NSUInteger categorySelectorOptions = CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION | CATEGORYSELECTOR_EXTRAACTION_ADD;
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc] initWithExtraActions:categorySelectorOptions];
    viewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:rect
                                  inView:self.displayPanel
                permittedArrowDirections:UIPopoverArrowDirectionDown
                                animated:YES];
}

- (IBAction)dayButtonPressed:(UIButton *)button
{
    [self launchPopoverForSelectDayFromRect:button.frame];
}

- (void)launchPopoverForSelectDayFromRect:(CGRect)rect
{
    
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController
{
    return YES;
}

#pragma IAECategorySelectorViewControllerDelegate

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
                     didSelectCategory:(IAECategory *)category
{
    self.actualCategory = category;
    [self configureDisplayPanelWithActualCategory];
    
    [self dismissPopover];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
            didSelectAddCategoryOfType:(CategoryType)categoryType
{
    
}


#pragma mark - IAECalendarSelectorViewControllerDelegate

- (void)dayCalendarSelectorViewController:(IAEDayCalendarSelectorViewController *)dayCalendarSelectorViewController
                             didSelectDay:(NSUInteger)day
{
    
}

#pragma mark - Notification Center

- (void)notificationCenterOnDayModeOn:(NSNotification *)notification
{
    [self configureDisplayPanelWithActualDay];
}

- (void)notificationCenterOnDayModeOff:(NSNotification *)notification
{
    [self configureDisplayPanelWithActualDay];
}



@end
