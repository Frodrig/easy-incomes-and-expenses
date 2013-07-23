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
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAEBook.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAECalculatorViewControllerDataSource.h"
#import "IAECategorySelectorViewController.h"
#import "IAEDayCalendarSelectorViewController.h"
#import "IAECategoryEditorViewController.h"

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
    [self processDragPannelButtonPressedWithMode:CM_INCOME];
}

- (IBAction)expenseButtonPressed:(id)sender
{
    [self processDragPannelButtonPressedWithMode:CM_EXPENSE];
}

- (void)processDragPannelButtonPressedWithMode:(CalculatorMode)mode
{
    NSAssert(mode != CM_HIDE, @"");
    
    if ([self isInHideMode]) {
        [self showInMode:mode];
    } else if ([self isDragPannelModeEqualToMode:mode]) {
        [self hide];
    } else {
        NSAssert(![self isDragPannelModeEqualToMode:mode], @"");
        [self changeToMode:mode];
    }
}

- (void)setDefaultCategoryForActualMode
{
    if (self.mode == CM_INCOME) {
        self.actualCategory = [[IAECategoryStore sharedCategoryStore] generalIncomeCategory];
    } else if (self.mode == CM_EXPENSE) {
        self.actualCategory = [[IAECategoryStore sharedCategoryStore] generalExpenseCategory];
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
    [self setDefaultCategoryForActualMode];
    [self configureDisplayPanelInShowMode];
    
    [self.delegate showButtonPressedOnCalculatorViewController:self];
}

- (void)changeToMode:(CalculatorMode)mode
{
    self.mode = mode;
    
    [self setDefaultCategoryForActualMode];
    [self configureDisplayPanelWithActualCategory];
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
    self.popover.popoverContentSize = viewController.view.frame.size;
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:rect
                                  inView:self.displayPanel
                permittedArrowDirections:UIPopoverArrowDirectionDown
                                animated:YES];
    
    [viewController changeToCategory:self.actualCategory.categoryType];
}

- (IBAction)dayButtonPressed:(UIButton *)button
{
    [self launchPopoverForSelectDayFromRect:button.frame];
}

- (void)launchPopoverForSelectDayFromRect:(CGRect)rect
{
    IAEYear *year = [self.dataSource yearForCalculatorViewController:self];
    IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
    IAEDayCalendarSelectorViewController *viewController = [[IAEDayCalendarSelectorViewController alloc] initWithYearDate:year.yearDate
                                                                                                               monthIndex:month.month
                                                                                                           andDaySelected:self.actualDay];
    viewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.popoverContentSize = viewController.view.frame.size;
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:rect
                                  inView:self.displayPanel
                permittedArrowDirections:UIPopoverArrowDirectionDown
                                animated:YES];
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
    [self changeActualCategoryTo:category];
    
    [self dismissPopover];
}

- (void)changeActualCategoryTo:(IAECategory *)category
{
    self.actualCategory = category;
    self.mode = category.categoryType == IncomeCategory ? CM_INCOME : CM_EXPENSE;
    [self configureDisplayPanelWithActualCategory];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
            didSelectAddCategoryOfType:(CategoryType)categoryType
{
    [self dismissPopover];

    IAECategoryEditorViewController *categoryEditorViewController = [[IAECategoryEditorViewController alloc] initToAddCategoryOfType:categoryType];
    categoryEditorViewController.delegate = self;
    categoryEditorViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    
    [self presentViewController:categoryEditorViewController animated:YES completion:nil];
}

#pragma mark - IAECalendarSelectorViewControllerDelegate

- (void)dayCalendarSelectorViewController:(IAEDayCalendarSelectorViewController *)dayCalendarSelectorViewController
                             didSelectDay:(NSUInteger)day
{
    self.actualDay = day;
    [self configureDisplayPanelWithActualDay];
    
    [self dismissPopover];
}

#pragma mark - IAECategoryEditorViewControllerDelegate

- (void)cancelButtonWasPressedInCategoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
{
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           DidValidateNewCategoryTag:(NSString *)categoryTag
                      ofCategoryType:(CategoryType)categoryType
{
    // ToDo: Valorar que la creacion se realice en el editor de categorias para factorizar en un unico sitio la creacion
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] createCategoryOfType:categoryType andTag:categoryTag withValidityTagCheck:NO];
    NSAssert(category, @"");
    [[IAEBook sharedBook] saveAll];

    [self changeActualCategoryTo:category];

    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           DidValidateRenameCategory:(IAECategory *)category
                             withTag:(NSString *)tag
{
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
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
