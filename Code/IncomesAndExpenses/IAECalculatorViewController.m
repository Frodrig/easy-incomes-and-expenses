//
//  IAECalculatorViewController.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECalculatorViewController.h"
#import "Flurry.h"
#import "IAEDragPanelCalculatorView.h"
#import "IAEDisplayPanelCalculatorView.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "IAEMonth.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEOpenYear.h"
#import "IAECalculatorViewControllerDelegate.h"
#import "IAECalculatorViewControllerDataSource.h"
#import "IAECategorySelectorViewController.h"
#import "IAEDayCalendarSelectorViewController.h"
#import "IAECategoryEditorViewController.h"
#import "IAECurrencyManager.h"
#import "IAEDateHelper.h"
#import "IAENumberFormatterManager.h"
#import "IAEFavoriteConceptsViewController.h"
#import "IAEKeyboardPanelCalculatorView.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "UIView+FloatingAnimation.h"

@interface IAECalculatorViewController ()

typedef NS_ENUM(NSUInteger, CalculatorMode) {
    CM_HIDE,
    CM_INCOME,
    CM_EXPENSE
};

typedef NS_ENUM(NSUInteger, KeyboardActionType) {
    KeyboardActionTypeInvalid,
    KeyboardActionTypeValidAdd,
    KeyboardActionTypeValidFavorites
};

@property (weak, nonatomic) IBOutlet IAEDisplayPanelCalculatorView *displayPanel;
@property (weak, nonatomic) IBOutlet IAEKeyboardPanelCalculatorView *keyboardPanel;
@property (weak, nonatomic) IBOutlet UIButton *incomeButton;
@property (weak, nonatomic) IBOutlet UIButton *expenseButton;
@property (weak, nonatomic) IBOutlet UIImageView *pinFavoriteImage;
@property (nonatomic) CalculatorMode mode;
@property (nonatomic, strong) IAECategory *actualCategory;
@property (nonatomic) NSUInteger actualDay;
@property (nonatomic, strong) NSMutableString *actualAmount;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, weak) UIView *currentFloatingDisplayButtonView;
@property (nonatomic, strong) NSDecimalNumber *maxDecimalNumberAllowed;
@property (nonatomic) NSUInteger numberConceptsCreatedInSession;
@property (nonatomic) CGPoint centerPositionBeforeDisable;
@property (nonatomic, strong) UIColor *validActionBaseColor;
@property (nonatomic, strong) UIColor *validActionTransitionColor;
@property (nonatomic, strong) UIColor *invalidActionBaseColor;
@property (nonatomic, strong) UIColor *invalidActionTransitionColor;
@property (nonatomic, weak) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic) CGRect frameInHideMode;
@property (nonatomic) CGRect frameInVisibleMode;
@property (nonatomic, readwrite, getter = isInDisableMode) BOOL disableMode;
@property (nonatomic, readwrite, getter = isInDragMode) BOOL dragMode;
@property (nonatomic) BOOL automaticDragMode;
@property (nonatomic) CalculatorMode previousCalculatorMode;

@end

@implementation IAECalculatorViewController

@synthesize sizeHeightOfDragPanel = _sizeHeightOfDragPanel;

static const CGFloat kAnimationDurationShowHideAction = 0.5;
static const CGFloat kMarginHeightOffsetWhenShowed = 10;

static NSString * const kUserDefaultsDayModeActive = @"dayModeActive";
static NSString * const kNotificationDayModeOnName = @"dayModeToOn";
static NSString * const kNotificationDayModeOffName = @"dayModeToOff";

static const NSUInteger kAmountMaxNumbersLenght = 15;
static const NSUInteger kAmountMaxNumberLenghtInDecimalPart = 2;

static const CGFloat kAnimationDurationForDisableAction = 0.5;
static const CGFloat kRatioOfDragPanelVisibleForDisableAction = 0.55;

static const CGFloat kRatioToDecideHideInDrag = 1.4;

static const CGFloat kDurationInvalidActionFXFadeIn = 0.05;
static const CGFloat kDurationInvalidActionFXFadeOut = 0.15;

static const NSUInteger kPopoverYOffsetForFavoriteConceptsViewController = 24;

static NSString * const kCategoryKey = @"category";
static NSString * const kValueKey = @"value";

static const CGFloat kUpdateFavoritePinAnimationTime = 0.35;

static const NSUInteger kPopoverAdditionalHeightAmountForChangeCategory = 360;

#pragma mark - Properties

- (NSString *)actualAmount
{
    if (!_actualAmount) {
        _actualAmount = [NSMutableString string];
    }
    
    return _actualAmount;
}

- (NSDecimalNumber *)maxDecimalNumberAllowed
{
    if (!_maxDecimalNumberAllowed) {
        _maxDecimalNumberAllowed = [NSDecimalNumber decimalNumberWithString:@"9999999999999" locale:[NSLocale currentLocale]];
    }
    
    return _maxDecimalNumberAllowed;
}

- (CGFloat)sizeHeightOffsetWhenShowed
{
    return [self calculeAbsoluteOffsetDisplacementValue] + kMarginHeightOffsetWhenShowed;
}

- (CGFloat)sizeHeightOfDragPanel
{
    if (_sizeHeightOfDragPanel == 0) {
        _sizeHeightOfDragPanel = self.dragPanel.bounds.size.height;
    }
    
    return _sizeHeightOfDragPanel;
}

- (UIColor *)invalidActionBaseColor
{
    if (!_invalidActionBaseColor) {
        _invalidActionBaseColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.05];
    }
    
    return _invalidActionBaseColor;
}

- (UIColor *)invalidActionTransitionColor
{
    if (!_invalidActionTransitionColor) {
        _invalidActionTransitionColor = [UIColor colorWithRed:1 green:0.0 blue:0.0 alpha:0.15];
    }
    
    return _invalidActionTransitionColor;
}

- (UIColor *)validActionBaseColor
{
    if (!_validActionBaseColor) {
        _validActionBaseColor = [UIColor colorWithWhite:0.8 alpha:0.0];
    }
    
    return _validActionBaseColor;
}

- (UIColor *)validActionTransitionColor
{
    if (!_validActionTransitionColor) {
        _validActionTransitionColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    }
    
    return _validActionTransitionColor;
}

#pragma mark - Init

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
    _previousCalculatorMode = CM_HIDE;
    self.view.autoresizingMask = UIViewAutoresizingNone;
    _actualDay = [IAEDateHelper findPresentDayOfThePresentMonth];
}

- (void)initAsObserverOfNotificationCenter
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOn:)
                                                 name:kNotificationDayModeOnName
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(notificationCenterOnDayModeOff:)
                                                 name:kNotificationDayModeOffName
                                               object:nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self configureDisplayPanelCalculatorView];
    [self configureInitialVisibilityOfPinFavoriteImage];
}

- (void)configureDisplayPanelCalculatorView
{
    self.displayPanel.delegate = self;
    self.displayPanel.dataSource = self;
}

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

- (void)configureInitialVisibilityOfPinFavoriteImage
{
    self.pinFavoriteImage.hidden = [[NSUserDefaults standardUserDefaults] isProVersionDisabled];
}

#pragma mark - Enabled & Disabled

- (void)disable
{
    if ([self isDisabeOptionAvailable]) {
        [UIView animateWithDuration:kAnimationDurationForDisableAction animations:^{
            self.view.center = CGPointMake(self.view.center.x,
                                           self.view.center.y + self.dragPanel.bounds.size.height * kRatioOfDragPanelVisibleForDisableAction);
        }];
        [self setIncomeAndExpenseButtonsInEnableState:NO];
        self.disableMode = YES;
    }
}

- (void)enable
{
    if (self.disableMode) {
        [UIView animateWithDuration:kAnimationDurationForDisableAction animations:^{
            self.view.center = CGPointMake(self.view.center.x,
                                           self.view.center.y - self.dragPanel.bounds.size.height * kRatioOfDragPanelVisibleForDisableAction);
        }];
        [self setIncomeAndExpenseButtonsInEnableState:YES];
        self.disableMode = NO;
    }
}

- (void)setIncomeAndExpenseButtonsInEnableState:(BOOL)enabledState
{
    [self.incomeButton setEnabled:enabledState];
    [self.expenseButton setEnabled:enabledState];
}

- (BOOL)isDisabeOptionAvailable
{
    return ([self isInHideMode] && !self.disableMode);
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

- (BOOL)isOpen
{
    return [self isInExpenseMode] || [self isInIncomeMode];
}

- (BOOL)isClosed
{
    return ![self isOpen];
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
    
    [self configureDisplayPanelWithActualCategoryWithAnimation:NO];
    [self configureDisplayPanelWithActualDayWithAnimation:NO];
    [self configureDisplayPanelWithActualAmount];
    [self setDisplayColorUsingAnimation:NO];
}

- (void)configureDisplayPanelWithActualCategoryWithAnimation:(BOOL)animation
{
    [self.displayPanel setCategoryName:[self.actualCategory localizedTag]];
    [self setDisplayColorUsingAnimation:animation];
}

- (void)configureDisplayPanelWithActualDayWithAnimation:(BOOL)animation
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:kUserDefaultsDayModeActive]) {
        [self.displayPanel setDay:[self findDayForNewConcept]
                  withDayweekName:[self findDayOfTheWeekName]
                      inMonthName:[self findMonthName]
                       ofYearName:[self findYearName]];
        if (animation) {
            [self setDisplayColorUsingAnimation:animation];
        }
    } else {
        [self.displayPanel setMonthName:[self findMonthName]
                             ofYearName:[self findYearName]];
    }
}

- (NSString *)findMonthName
{
    IAEMonth *actualMonth = [self.dataSource monthForCalculatorViewController:self];
    
    return [actualMonth monthAsString];
}

- (NSString *)findYearName
{
    IAEOpenYear *actualYear = [self.dataSource yearForCalculatorViewController:self];
    
    return [actualYear yearDateAsString];
}

- (NSString *)findDayOfTheWeekName
{
    IAEMonth *actualMonth = [self.dataSource monthForCalculatorViewController:self];
    NSUInteger dayOfTheWeekIndex = [IAEDateHelper findDayOfTheWeekIndexFromYearDate:actualMonth.year.yearDate
                                                                         monthIndex:actualMonth.month
                                                                   andDayOfTheMonth:[self findDayForNewConcept]];
    NSString *dayOfTheWeekName = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:dayOfTheWeekIndex inShortForm:NO];
    
    return dayOfTheWeekName;
}

- (BOOL)isDragPannelModeEqualToMode:(CalculatorMode)mode
{
    return mode == self.mode;
}

- (void)showInMode:(CalculatorMode)mode
{
    NSAssert(mode != CM_HIDE, @"");
    self.mode = mode;
    [self updateVisibilityToShow:YES usingAnimation:YES];
    [self prepareActualMode];
    [self.delegate showButtonWasPressedOnCalculatorViewController:self];
}

- (void)prepareActualMode
{
    [self setDefaultCategoryForActualMode];
    [self configureDisplayPanelInShowMode];
}

- (void)changeToMode:(CalculatorMode)mode
{
    self.mode = mode;
    
    [self setDefaultCategoryForActualMode];
    [self configureDisplayPanelWithActualCategoryWithAnimation:YES];
    [self setDisplayColorUsingAnimation:YES];
}

- (void)hide
{
    [self hideWithAnimation:YES];
}

- (void)hideWithoutAnimation
{
    [self hideWithAnimation:NO];
}

- (void)hideWithAnimation:(BOOL)animation
{
    self.previousCalculatorMode = self.mode;
    self.actualDay = [IAEDateHelper findPresentDayOfThePresentMonth];
    self.mode = CM_HIDE;
    [self updateVisibilityToShow:NO usingAnimation:animation];
    [self.delegate calculatorViewController:self hideButtonWasPressedWithAnimation:animation];
}

- (CGFloat)calculeAbsoluteOffsetDisplacementValue
{
    return self.view.bounds.size.height - self.dragPanel.bounds.size.height;
}

- (void)updateVisibilityToShow:(BOOL)show usingAnimation:(BOOL)animation
{
    self.automaticDragMode = YES;
    [UIView animateWithDuration:animation ? kAnimationDurationShowHideAction : 0.0 animations:^{
        self.view.frame = show ? self.frameInVisibleMode : self.frameInHideMode;
    } completion:^(BOOL finished) {
        [self resetAmountPannel];
        self.automaticDragMode = NO;
    }];
}

#pragma mark - Display Panel Events

- (void)launchPopoverForSelectFavoriteConceptsFromAddButton:(UIButton *)addButton
{
    IAEFavoriteConceptsViewController *favoriteConceptsViewController = [[IAEFavoriteConceptsViewController alloc] initWithOptions:FC_ADD];
    favoriteConceptsViewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:favoriteConceptsViewController];
    self.popover.popoverContentSize = favoriteConceptsViewController.view.frame.size;
    self.popover.delegate = self;
    
    CGRect presentRect = CGRectMake(addButton.frame.origin.x,
                                    addButton.frame.origin.y + kPopoverYOffsetForFavoriteConceptsViewController,
                                    addButton.frame.size.width,
                                    addButton.frame.size.height);
    [self.popover presentPopoverFromRect:presentRect inView:self.keyboardPanel permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (IBAction)categoryButtonPressed:(UIButton *)button
{
    CGRect rect = [button convertRect:button.frame toView:self.displayPanel];
    [self startCurrentFloatingDisplayButtonWithView:button];
    [self launchPopoverForSelectCategoryFromRect:rect];
}

- (void)startCurrentFloatingDisplayButtonWithView:(UIView *)floatingView
{
    self.currentFloatingDisplayButtonView = floatingView;
    [self.currentFloatingDisplayButtonView startFloatingAnimation];
}

- (void)launchPopoverForSelectCategoryFromRect:(CGRect)rect
{
    NSUInteger categorySelectorOptions = CATEGORYSELECTOR_EXTRAACTION_CATEGORYSELECTION | CATEGORYSELECTOR_EXTRAACTION_ADD;
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc] initWithExtraActions:categorySelectorOptions
                                                                                                   withSelectedCategory:self.actualCategory];
    viewController.view.frame = CGRectMake(CGRectGetWidth(rect), CGRectGetHeight(rect) / 2.0, viewController.view.bounds.size.width, viewController.view.bounds.size.height + kPopoverAdditionalHeightAmountForChangeCategory);
    
    viewController.showNumberOfConcepts = NO;
    viewController.delegate = self;

    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.popoverContentSize = viewController.view.frame.size;
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:rect
                                  inView:self.displayPanel
                permittedArrowDirections:UIPopoverArrowDirectionLeft
                                animated:YES];
}

- (IBAction)dayButtonPressed:(UIButton *)button
{
    CGRect rect = [button convertRect:button.frame toView:self.displayPanel];
    [self startCurrentFloatingDisplayButtonWithView:button];
    [self launchPopoverForSelectDayFromRect:rect];
}

- (void)launchPopoverForSelectDayFromRect:(CGRect)rect
{
    IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
    IAEDayCalendarSelectorViewController *viewController = [[IAEDayCalendarSelectorViewController alloc] initWithYearDate:month.year.yearDate
                                                                                                               monthIndex:month.month
                                                                                                           andDaySelected:[self findDayForNewConcept]];
    viewController.delegate = self;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.popoverContentSize = viewController.view.frame.size;
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:rect
                                  inView:self.displayPanel
                permittedArrowDirections:UIPopoverArrowDirectionDown
                                animated:YES];
}

- (IBAction)keyboardNumberPressed:(UIButton *)button
{
    const BOOL validAction = [self numberPressedWithValue:button.tag];
    [self doFXAfterPressedButton:button withActionType:validAction ? KeyboardActionTypeValidAdd : KeyboardActionTypeInvalid];
}

- (IBAction)keyboardDeletePressed:(UIButton *)button
{
    const BOOL validAction = [self deleteOneValueInAmount];
    if (validAction) {
        [self configureDisplayPanelWithActualAmount];
    }
    
    [self doFXAfterPressedButton:button withActionType:validAction ? KeyboardActionTypeValidAdd : KeyboardActionTypeInvalid];
}

- (BOOL)deleteOneValueInAmount
{
    BOOL canDelete = [self canDeleteOneValueInAmount];
    if (canDelete) {
        [self.actualAmount deleteCharactersInRange:NSMakeRange(self.actualAmount.length - 1, 1)];
        [self updateFavoritePinWithAnimation:YES];
    }
    
    return canDelete;
}

- (BOOL)canDeleteOneValueInAmount
{
    BOOL canDelete = [self actualAmountWithData];
    if (canDelete) {
        NSDecimalNumber *actualNumberAmount = [self convertToDecimalNumberKeyboardAmountValue:self.actualAmount];
        canDelete = ![actualNumberAmount isEqualToValue:[NSDecimalNumber zero]];
        if (!canDelete) {
            canDelete = [self isDecimalSymbolPressentInAmountStringValue:self.actualAmount];
        }
    }
    
    return canDelete;
}

- (BOOL)actualAmountWithData
{
    return self.actualAmount.length > 0;
}

- (NSDecimalNumber *)convertToDecimalNumberKeyboardAmountValue:(NSString *)amountValue
{
    // Nota: La conversion es necesaria porque NSDecimalNumber no entiende un decimal con ',' solo con '.'
    NSMutableString *amountValueForDecimalConversion = [NSMutableString stringWithString:amountValue];
    [amountValueForDecimalConversion replaceOccurrencesOfString:[[IAECurrencyManager sharedManager] decimalSeparator]
                                                     withString:@"."
                                                        options:NSBackwardsSearch
                                                          range:NSMakeRange(0, amountValueForDecimalConversion.length)];
    NSDecimalNumber *decimal = [NSDecimalNumber decimalNumberWithString:amountValueForDecimalConversion];
    
    return decimal;
}

- (IBAction)keyboardDecimalPressed:(UIButton *)button
{
    BOOL validAction = [self appendDecimalSeparatorInAmount];
    if (validAction) {
        [self configureDisplayPanelWithActualAmount];
    }
    
    [self doFXAfterPressedButton:button withActionType:validAction ? KeyboardActionTypeValidAdd : KeyboardActionTypeInvalid];
}

- (BOOL)appendDecimalSeparatorInAmount
{
    BOOL canAppend = [self canAppendDecimalSeparator];
    if (canAppend) {
        NSString *decimalSeparator = [[IAECurrencyManager sharedManager] decimalSeparator];
        self.actualAmount = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, decimalSeparator];
        [self updateFavoritePinWithAnimation:YES];
    }
    
    return canAppend;
}

- (BOOL)canAppendDecimalSeparator
{
    BOOL decimalSymbolPresent = [self isDecimalPresent];
    
    return decimalSymbolPresent ? NO : self.actualAmount.length <= kAmountMaxNumbersLenght - 1;
}

- (BOOL)isDecimalPresent
{
    return [self findDecimalRangeLocationInAmountString:self.actualAmount].location == NSNotFound ? NO : YES;
}

- (IBAction)keyboardEnterPressed:(UIButton *)button
{
    KeyboardActionType actionType = KeyboardActionTypeValidAdd;
    
    if ([self isActualAmountOverZero]) {
        [self createNewConcept];
    } else if ([self isFavoritePinActive] && [[NSUserDefaults standardUserDefaults] isProVersionEnabled]) {
        [self launchPopoverForSelectFavoriteConceptsFromAddButton:button];
        actionType = KeyboardActionTypeValidFavorites;
    } else {
        actionType = KeyboardActionTypeInvalid;
    }
    
    [self doFXAfterPressedButton:button withActionType:actionType];
    if (actionType == KeyboardActionTypeValidAdd) {
        [self setDisplayColorUsingAnimation:YES];
    }
}

- (void)createNewConcept
{
    IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
    IAEConcept *newConcept = [month addConceptWithAmount:[self convertToDecimalNumberKeyboardAmountValue:self.actualAmount]
                                                category:self.actualCategory
                                                    date:[[NSDate date] timeIntervalSince1970]
                                           dayOfTheMonth:[self findDayForNewConcept]
                                          andDescription:@""];
    self.numberConceptsCreatedInSession++;
    [[IAEBook sharedBook] saveAll];
    
    [self resetAmountPannel];
    
    [self.delegate calculatorViewController:self didCreateNewConcept:newConcept];
}


- (void)doFXAfterPressedButton:(UIButton *)button withActionType:(KeyboardActionType)actionType
{
    [self applyPressedAnimationOverButton:button withActionType:actionType];
}

- (void)applyPressedAnimationOverButton:(UIButton *)button withActionType:(KeyboardActionType)actionType
{
    button.backgroundColor = actionType != KeyboardActionTypeInvalid ? self.validActionBaseColor : self.invalidActionTransitionColor;
    [UIView animateWithDuration:kDurationInvalidActionFXFadeIn animations:^{
        button.backgroundColor = actionType != KeyboardActionTypeInvalid ? self.validActionTransitionColor : self.invalidActionTransitionColor;
    } completion:^(BOOL finished) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:kDurationInvalidActionFXFadeOut animations:^{
            button.backgroundColor = actionType != KeyboardActionTypeInvalid ? self.validActionBaseColor : self.invalidActionBaseColor;
        } completion:^(BOOL finished) {
            button.backgroundColor = [UIColor clearColor];
        }];
    }];
}

#pragma mark - Keyboard

- (BOOL)numberPressedWithValue:(NSUInteger)value
{
    BOOL validAction = [self appendNewNumberToAmountWithValue:value];
    if (validAction) {
        [self configureDisplayPanelWithActualAmount];
    }
    
    return validAction;
}

- (BOOL)appendNewNumberToAmountWithValue:(NSUInteger)value
{
    NSAssert(value >= 0 && value < 10, @"");

    BOOL canAppend = [self canAppendNewNumberToAmountWithValue:value];
    if (canAppend) {
        NSString *stringValue = [[NSNumber numberWithUnsignedInteger:value] stringValue];
        self.actualAmount = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, stringValue];
        [self updateFavoritePinWithAnimation:YES];
    }
    
    return canAppend;
}

- (BOOL)canAppendNewNumberToAmountWithValue:(NSUInteger)value
{
    NSAssert(value >= 0 && value < 10, @"");

    const BOOL withValueValidForActualState = [self isActualStateValidToAddValue:value];
    const BOOL withSpaceForNewNumber = [self isActualAmountWithSpaceForNewValue];
    const BOOL withSpaceForDecimalNumber = [self isActualAmountWithSpaceForNewDecimalNumber];
    const BOOL withValueUnderMaxAllowed = [self isActualAmountUnderMaxDecimalNumberAllowedWithNewValue:value];
    const BOOL can = withValueValidForActualState && withSpaceForNewNumber && withSpaceForDecimalNumber && withValueUnderMaxAllowed;
    
    return can;
}

- (BOOL)isActualStateValidToAddValue:(NSUInteger)value
{
    return (value > 0 || (value == 0 && [self isActualAmountOverZero])) || [self isDecimalPresent];
}

- (BOOL)isActualAmountOverZero
{
    BOOL overZero = NO;
    if ([self actualAmountWithData]) {
        NSDecimalNumber *actualAmount = nil;
        if ([self isDecimalPresent]) {
            NSString *validActualAmountString = [self createDecimalNumberConvertibleStringFromActualAmountString];
            actualAmount = [NSDecimalNumber decimalNumberWithString:validActualAmountString];
        } else {
            actualAmount = [NSDecimalNumber decimalNumberWithString:self.actualAmount];
        }
        
        overZero = [actualAmount compare:[NSDecimalNumber decimalNumberWithString:@"0"]] != NSOrderedSame ? YES : NO;
    }
    
    return overZero;
}

- (NSString *)createDecimalNumberConvertibleStringFromActualAmountString
{
    NSString *validActualAmountString = [NSString stringWithString:self.actualAmount];
    NSRange decimalRange = [self findDecimalRangeLocationInAmountString:self.actualAmount];
    if (decimalRange.location == 0) {
        validActualAmountString = [NSString stringWithFormat:@"0%@", validActualAmountString];
    }
    if (decimalRange.location == self.actualAmount.length - 1) {
        validActualAmountString = [NSString stringWithFormat:@"%@0", validActualAmountString];
    }
    validActualAmountString = [validActualAmountString stringByReplacingOccurrencesOfString:@"," withString:@"."];
    
    return validActualAmountString;
}

- (BOOL)isActualAmountWithSpaceForNewValue
{
    return self.actualAmount.length <= kAmountMaxNumbersLenght;
}

- (BOOL)isActualAmountWithSpaceForNewDecimalNumber
{
    BOOL spaceAvailable = [self characterSpaceForDecimalNumbers] > 0;
    
    return spaceAvailable;
}

- (NSUInteger)characterSpaceForDecimalNumbers
{
    NSRange decimalRange = [self findDecimalRangeLocationInAmountString:self.actualAmount];
    NSUInteger space = kAmountMaxNumberLenghtInDecimalPart;
    if (decimalRange.location != NSNotFound) {
        space -= (self.actualAmount.length - (decimalRange.location + 1));
    }
   
    return space;
}

- (NSRange)findDecimalRangeLocationInAmountString:(NSString *)amount
{
    NSString *decimalSeparator = [[IAECurrencyManager sharedManager] decimalSeparator];
    NSRange decimalRange = [amount rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:decimalSeparator]];
    
    return decimalRange;
}

- (BOOL)isActualAmountUnderMaxDecimalNumberAllowedWithNewValue:(NSUInteger)value
{
    NSString *stringValue = [[NSNumber numberWithUnsignedInteger:value] stringValue];
    NSString *tmpValue = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, stringValue];
    NSDecimalNumber *tmpNumberValue = [NSDecimalNumber decimalNumberWithString:tmpValue];
    const BOOL underActualAmount = [tmpNumberValue compare:self.maxDecimalNumberAllowed] != NSOrderedDescending;
    
    return underActualAmount;
}

- (void)configureDisplayPanelWithActualAmount
{
    NSString *amountStringToDisplay = nil;
    IAENumberFormatterManager *currencyManager = [IAENumberFormatterManager sharedManager];
    [currencyManager saveCurrencyFormatterFractionState];

    if ([self actualAmountWithData]) {
        NSUInteger maximumFractionDigits = [self findMaximumFractionDigitsToDisplayForAmountValue:self.actualAmount];
        currencyManager.currencyFormatter.maximumFractionDigits = maximumFractionDigits;
        amountStringToDisplay = [self convertToAmountStringDisplayableTheAmountString:self.actualAmount];
        amountStringToDisplay = [self stringWithDecimalSeparatorAddedManuallyIfAppropiateFromStringAmount:self.actualAmount
                                                                                  toAmountStringToDisplay:amountStringToDisplay];
    } else {
        currencyManager.currencyFormatter.maximumFractionDigits = 0;
        amountStringToDisplay = [self convertToAmountStringDisplayableTheAmountString:@"0"];
    }
    
    [currencyManager restoreCurrencyFormatterFractionState];
    [self.displayPanel setAmountString:amountStringToDisplay];
}

- (NSString *)convertToAmountStringDisplayableTheAmountString:(NSString *)amountValue
{
    NSDecimalNumber *actualAmountDecimal = [self convertToDecimalNumberKeyboardAmountValue:amountValue];
    NSString *amountStringDisplayable = [NSMutableString stringWithString:[[IAENumberFormatterManager sharedManager].currencyFormatter
                                                                           stringFromNumber:actualAmountDecimal]];
    
    return amountStringDisplayable;
}

- (NSString *)stringWithDecimalSeparatorAddedManuallyIfAppropiateFromStringAmount:(NSString *)stringAmount
                                                          toAmountStringToDisplay:(NSString *)amountStringToDisplay
{
    NSRange locationOfDecimalInActualAmount = [self findDecimalRangeLocationInAmountString:stringAmount];
    NSRange locationOfDecimalInAmountStringToDisplay = [self findDecimalRangeLocationInAmountString:amountStringToDisplay];
   
    BOOL needToInsertDecimalSeparatorManually = locationOfDecimalInActualAmount.location != NSNotFound &&
                                                locationOfDecimalInAmountStringToDisplay.location == NSNotFound;
    if (needToInsertDecimalSeparatorManually) {
        NSString *amountStringToDisplayWithoutCurrencySymbol = [amountStringToDisplay stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:[[IAECurrencyManager sharedManager] currencySymbol]]];
        amountStringToDisplayWithoutCurrencySymbol = [amountStringToDisplayWithoutCurrencySymbol stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSRange amountRangeInStringToDisplay = [amountStringToDisplay rangeOfString:amountStringToDisplayWithoutCurrencySymbol];
        
        NSMutableString *composedString = [NSMutableString stringWithString:amountStringToDisplay];
        [composedString insertString:[[IAECurrencyManager sharedManager] decimalSeparator] atIndex:amountRangeInStringToDisplay.location + amountRangeInStringToDisplay.length];
        amountStringToDisplay = [NSString stringWithString:composedString];
    }
    
    return amountStringToDisplay;
}

- (NSUInteger)findMaximumFractionDigitsToDisplayForAmountValue:(NSString *)amountValue
{
    NSUInteger maximumFractionDigits = 2;
    
    NSRange decimalRange = [self findDecimalRangeLocationInAmountString:amountValue];
    if (decimalRange.location == NSNotFound || decimalRange.location == amountValue.length - 1) {
        maximumFractionDigits = 0;
    } else if (decimalRange.location == amountValue.length - 2) {
        maximumFractionDigits = 1;
    }
    
    return maximumFractionDigits;
}

- (BOOL)isDecimalSymbolPressentInAmountStringValue:(NSString *)amountString
{
    NSRange decimalRange = [self findDecimalRangeLocationInAmountString:amountString];
    return decimalRange.location == NSNotFound ? NO : YES;
}

- (void)setDisplayColorUsingAnimation:(BOOL)animation
{
    if ([self isInIncomeMode]) {
        [self.displayPanel setDisplayWithIncomeColorUsingAnimation:animation];
    } else if ([self isInExpenseMode]) {
        [self.displayPanel setDisplayExpenseColorUsingAnimation:animation];
    }
}

- (void)resetAmountPannel
{
    self.actualAmount = nil;
    [self configureDisplayPanelWithActualAmount];
    [self updateFavoritePinWithAnimation:YES];
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
    [self endFloatingDisplayButtonView];
}

- (void)endFloatingDisplayButtonView
{
    [self.currentFloatingDisplayButtonView endCurrentFloatingAnimation];
    self.currentFloatingDisplayButtonView = nil;
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
    [self dismissPopoverAndEndFloatingDisplayButtonView];
}

- (void)dismissPopoverAndEndFloatingDisplayButtonView
{
    [self dismissPopover];
    [self endFloatingDisplayButtonView];
}

- (void)changeActualCategoryTo:(IAECategory *)category
{
    self.actualCategory = category;
    self.mode = category.categoryType == IncomeCategory ? CM_INCOME : CM_EXPENSE;
    [self configureDisplayPanelWithActualCategoryWithAnimation:YES];
}

- (void)categorySelectorViewController:(IAECategorySelectorViewController *)categorySelectorViewController
            didSelectAddCategoryOfType:(CategoryType)categoryType
{
    [self dismissPopoverAndEndFloatingDisplayButtonView];

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
    [self configureDisplayPanelWithActualDayWithAnimation:YES];
    
    [self dismissPopoverAndEndFloatingDisplayButtonView];
}

#pragma mark - IAECategoryEditorViewControllerDelegate

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
             didCancelRenameCategory:(IAECategory *)category
{
    
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateNewCategoryTag:(NSString *)categoryTag
                      ofCategoryType:(CategoryType)categoryType
{
    [Flurry logEvent:@"calculator_newcategorycreated"];

    IAECategory *category = [[IAECategoryStore sharedCategoryStore] createCategoryOfType:categoryType andTag:categoryTag withValidityTagCheck:NO];
    NSAssert(category, @"");
    [[IAEBook sharedBook] saveAll];

    [self changeActualCategoryTo:category];

    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
}

- (void)categoryEditorViewController:(IAECategoryEditorViewController *)categoryEditorViewController
           didValidateRenameCategory:(IAECategory *)category
                             withTag:(NSString *)tag
{
    [categoryEditorViewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Notification Center

- (void)notificationCenterOnDayModeOn:(NSNotification *)notification
{
    [self configureDisplayPanelWithActualDayWithAnimation:NO];
}

- (void)notificationCenterOnDayModeOff:(NSNotification *)notification
{
    //self.actualDay = 0;
    [self configureDisplayPanelWithActualDayWithAnimation:NO];
}

#pragma mark - IAEDisplayCalculatorViewDelegate

- (void)amountLabelWasCleanInDisplayPanelCalculatorView:(IAEDisplayPanelCalculatorView *)displayPanelCalculatorView
{
    [Flurry logEvent:@"calculator_strokeamount"];

    [self resetAmountPannel];
}

#pragma mark - Pan / Drag

- (void)calculeDragLimits
{
    CGFloat offsetDisplacement = [self calculeAbsoluteOffsetDisplacementValue];

    if ([self isInHideMode]) {
        self.frameInVisibleMode = CGRectMake(self.view.frame.origin.x,
                                             self.view.frame.origin.y - offsetDisplacement,
                                             self.view.frame.size.width,
                                             self.view.frame.size.height);
        self.frameInHideMode = self.view.frame;
    } else {
        self.frameInVisibleMode = self.view.frame;
        self.frameInHideMode = CGRectMake(self.view.frame.origin.x,
                                          self.view.frame.origin.y + offsetDisplacement,
                                          self.view.frame.size.width,
                                          self.view.frame.size.height);
    }
}

- (void)doDragTranslation:(CGFloat)translation
{
    if (![self isInDisableMode]) {
        self.view.center = CGPointMake(self.view.center.x, self.view.center.y + translation);
        if (self.view.frame.origin.y < self.frameInVisibleMode.origin.y) {
            self.view.frame = self.frameInVisibleMode;
        } else if (self.view.frame.origin.y > self.frameInHideMode.origin.y) {
            self.view.frame = self.frameInHideMode;
        }
    }
}

- (void)beginDragTranslation
{
    self.dragMode = YES;
    if (![self isInVisibleMode]) {
        self.mode = self.previousCalculatorMode == CM_HIDE ? CM_INCOME : self.previousCalculatorMode;
        [self prepareActualMode];
    }
}

- (void)endDragTranslation
{
    if ([self isInDragMode]) {
        self.dragMode = NO;
        if (self.view.frame.origin.y > self.frameInVisibleMode.origin.y * kRatioToDecideHideInDrag) {
            [self hide];
        } else {
            [self showInMode:self.mode];
        }
    }
}

- (void)addPanGestureRecognizer:(UIPanGestureRecognizer *)panGestureRecognizer
{
    self.panGestureRecognizer = panGestureRecognizer;
    [self.dragPanel addGestureRecognizer:panGestureRecognizer];
}

- (void)removePanGestureRecognizer
{
    [self.dragPanel removeGestureRecognizer:self.panGestureRecognizer];
    self.panGestureRecognizer = nil;
}

#pragma mark - IAEDisplayPanelCalculatorDataSource

- (BOOL)isDecimalPresentForDisplayPanelCalculatorView:(IAEDisplayPanelCalculatorView *)displayPanelCalculatorView
{
    return [self isDecimalPresent];
}

#pragma mark - Translation questions

- (BOOL)isAnyTranslationActive
{
    return self.isInDragMode || self.automaticDragMode;
}

#pragma mark - FavoritePinImage

- (void)updateFavoritePinWithAnimation:(BOOL)animation;
{
    const BOOL showPin = ![self actualAmountWithData] && [[NSUserDefaults standardUserDefaults] isProVersionEnabled];
    if (showPin == self.pinFavoriteImage.hidden) {
        if (animation) {
            [UIView animateWithDuration:kUpdateFavoritePinAnimationTime animations:^{
                if (showPin) {
                    self.pinFavoriteImage.hidden = NO;
                    self.pinFavoriteImage.alpha = 0.0;
                }
                self.pinFavoriteImage.alpha = showPin ? 1.0 : 0.0;
            } completion:^(BOOL finished) {
                if (!showPin && finished) {
                    self.pinFavoriteImage.hidden = YES;
                    self.pinFavoriteImage.alpha = 0;
                }
            }];
        } else {
            self.pinFavoriteImage.hidden = showPin;
        }
    }
}

- (BOOL)isFavoritePinActive
{
    return !self.pinFavoriteImage.hidden;
}

#pragma mark - IAEFavoriteConceptsViewControllerDelegate

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController
didPressedAddOptionWithFavoriteIncomes:(NSArray *)incomes
                           andExpenses:(NSArray *)expenses
{
    [self createFromFavoritesNewConcepts:incomes ofType:IncomeCategory];
    [self createFromFavoritesNewConcepts:expenses ofType:ExpenseCategory];
    
    [self.popover dismissPopoverAnimated:YES];
}

- (void)createFromFavoritesNewConcepts:(NSArray *)concepts ofType:(CategoryType)type
{
    NSMutableArray *newConcepts = [NSMutableArray arrayWithCapacity:concepts.count];
    
    IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
    for (NSDictionary *conceptIt in concepts) {
        NSString *category = conceptIt[kCategoryKey];
        NSString *value = conceptIt[kValueKey];
        IAEConcept *newConcept = [month addConceptWithAmount:[self convertToDecimalNumberKeyboardAmountValue:value]
                                                    category:[[IAECategoryStore sharedCategoryStore] findCategoryByTag:category]
                                                        date:[[NSDate date] timeIntervalSince1970]
                                               dayOfTheMonth:[self findDayForNewConcept]
                                              andDescription:@""];
        [newConcepts addObject:newConcept];
    }
    
    self.numberConceptsCreatedInSession += concepts.count;
    [[IAEBook sharedBook] saveAll];
    
    [self.delegate calculatorViewController:self didCreateNewConcepts:[NSArray arrayWithArray:newConcepts]];
}

- (NSUInteger)findDayForNewConcept
{
    NSUInteger retDay = self.actualDay;
    IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
    if (month.year.yearDate < [IAEDateHelper findPresentYearDate]) {
        retDay = [month daysOfTheMonth].unsignedIntegerValue;
    } else if (month.year.yearDate > [IAEDateHelper findPresentYearDate]) {
        retDay = 1;
    } else {
        NSAssert(month.year.yearDate == [IAEDateHelper findPresentYearDate], @"");
        if (month.month < [IAEDateHelper findPresentMonthOfThePresentYear]) {
            retDay = [month daysOfTheMonth].unsignedIntegerValue;
        } else if (month.month > [IAEDateHelper findPresentMonthOfThePresentYear]) {
            retDay = 1;
        }
    }
    
    return retDay;
}

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController willRemoveFavoriteWithCategory:(NSString *)category andValue:(NSString *)value
{
    // ...
}

- (void)favoriteConceptsViewController:(IAEFavoriteConceptsViewController *)favoriteConceptsViewController didRemoveFavoriteWithCategory:(NSString *)category andValue:(NSString *)value
{
    [self.delegate calculatorViewController:self didRemoveFavoriteConceptWithCategory:category andValue:value];
}

@end
