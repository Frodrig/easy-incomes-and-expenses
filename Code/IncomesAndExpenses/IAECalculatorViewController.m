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
#import "IAECurrencyManager.h"
#import "IAEDateHelper.h"

@interface IAECalculatorViewController ()

typedef NS_ENUM(NSUInteger, CalculatorMode) {
    CM_HIDE,
    CM_INCOME,
    CM_EXPENSE
};

@property (weak, nonatomic) IBOutlet IAEDragPanelCalculatorView *dragPanel;
@property (weak, nonatomic) IBOutlet IAEDisplayPanelCalculatorView *displayPanel;
@property (weak, nonatomic) IBOutlet UIButton *incomeButton;
@property (weak, nonatomic) IBOutlet UIButton *expenseButton;
@property (nonatomic) CalculatorMode mode;
@property (nonatomic, strong) IAECategory *actualCategory;
@property (nonatomic) NSUInteger actualDay;
@property (nonatomic, strong) NSMutableString *actualAmount;
@property (nonatomic, strong) UIPopoverController *popover;
@property (nonatomic, strong) NSDecimalNumber *maxDecimalNumberAllowed;
@property (nonatomic) NSUInteger numberConceptsCreatedInSession;
@property (nonatomic) CGPoint centerPositionBeforeDisable;

@end

@implementation IAECalculatorViewController

@synthesize sizeHeightOfDragPanel = _sizeHeightOfDragPanel;

static CGFloat animationDurationShowHideAction = 0.25;
static CGFloat marginHeightOffsetWhenShowed = 10;

static NSString * const userDefaultsDayModeActive = @"dayModeActive";
static NSString * const notificationDayModeOnName = @"dayModeToOn";
static NSString * const notificationDayModeOffName = @"dayModeToOff";

static NSUInteger amountMaxNumbersLenght = 15;
static NSUInteger amountMaxNumberLenghtInDecimalPart = 2;

static CGFloat animationDurationForDisableAction = 0.25;
static CGFloat ratioOfDragPanelVisiableForDisableAction = 0.55;

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
    return [self calculeAbsoluteOffsetDisplacementValue] + marginHeightOffsetWhenShowed;
}

- (CGFloat)sizeHeightOfDragPanel
{
    if (_sizeHeightOfDragPanel == 0) {
        _sizeHeightOfDragPanel = self.dragPanel.bounds.size.height;
    }
    
    return _sizeHeightOfDragPanel;
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
    self.view.autoresizingMask = UIViewAutoresizingNone;
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
    
    [self configureDisplayPanelCalculatorView];
}

- (void)configureDisplayPanelCalculatorView
{
    self.displayPanel.delegate = self;
}

- (void)dismissPopover
{
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

#pragma mark - Enabled & Disabled

- (void)disable
{
    if ([self isDisabeOptionAvailable]) {
        [UIView animateWithDuration:animationDurationForDisableAction animations:^{
            self.view.center = CGPointMake(self.view.center.x,
                                           self.view.center.y + self.dragPanel.bounds.size.height * ratioOfDragPanelVisiableForDisableAction);
        }];
        [self setIncomeAndExpenseButtonsInEnableState:NO];
        _disableMode = YES;
    }
}

- (void)enable
{
    if (self.disableMode) {
        [UIView animateWithDuration:animationDurationForDisableAction animations:^{
            self.view.center = CGPointMake(self.view.center.x,
                                           self.view.center.y - self.dragPanel.bounds.size.height * ratioOfDragPanelVisiableForDisableAction);
        }];
        [self setIncomeAndExpenseButtonsInEnableState:YES];
        _disableMode = NO;
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
    
    [self configureDisplayPanelWithActualCategory];
    [self configureDisplayPanelWithActualDay];
    [self configureDisplayPanelWithActualAmount];
}

- (void)configureDisplayPanelWithActualCategory
{
    [self.displayPanel setCategoryName:self.actualCategory.tag];
}

- (void)configureDisplayPanelWithActualDay
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:userDefaultsDayModeActive]) {
        [self.displayPanel showDayButton];
        [self.displayPanel setDay:self.actualDay
                    withDayweekName:[self findDayOfTheWeekName]
                      inMonthName:[self findMonthName]];
    } else {
        [self.displayPanel hideDayButton];
    }
}

- (NSString *)findMonthName
{
    IAEMonth *actualMonth = [self.dataSource monthForCalculatorViewController:self];
    
    return actualMonth.description;
}

- (NSString *)findDayOfTheWeekName
{
    IAEMonth *actualMonth = [self.dataSource monthForCalculatorViewController:self];
    NSUInteger dayOfTheWeekIndex = [IAEDateHelper findDayOfTheWeekIndexFromYearDate:actualMonth.year.yearDate
                                                                         monthIndex:actualMonth.month
                                                                   andDayOfTheMonth:self.actualDay];
    NSString *dayOfTheWeekName = [IAEDateHelper findDayOfTheWeekNameStringWithDayOfTheWeekIndex:dayOfTheWeekIndex inShortForm:NO];
    
    return dayOfTheWeekName;
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
    
    [self.delegate showButtonWasPressedOnCalculatorViewController:self];
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

    [self.delegate hideButtonWasPressedOnCalculatorViewController:self];
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
    IAECategorySelectorViewController *viewController = [[IAECategorySelectorViewController alloc] initWithExtraActions:categorySelectorOptions
                                                                                                withSelectedCategory:self.actualCategory];
    viewController.showNumberOfConcepts = NO;
    viewController.delegate = self;

    self.popover = [[UIPopoverController alloc] initWithContentViewController:viewController];
    self.popover.popoverContentSize = viewController.view.frame.size;
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

- (IBAction)keyboardNumberPressed:(UIButton *)button
{
    [self numberPressedWithValue:button.tag];
}

- (IBAction)keyboardDeletePressed:(UIButton *)button
{
    if ([self deleteOneValueInAmount]) {
        [self configureDisplayPanelWithActualAmount];
    }
}

- (BOOL)deleteOneValueInAmount
{
    BOOL canDelete = [self canDeleteOneValueInAmount];
    if (canDelete) {
        [self.actualAmount deleteCharactersInRange:NSMakeRange(self.actualAmount.length - 1, 1)];
    }
    
    return canDelete;
}

- (BOOL)canDeleteOneValueInAmount
{
    BOOL canDelete = self.actualAmount.length > 0;
    if (canDelete) {
        NSDecimalNumber *actualNumberAmount = [self convertToDecimalNumberKeyboardAmountValue:self.actualAmount];
        canDelete = ![actualNumberAmount isEqualToValue:[NSDecimalNumber zero]];
        if (!canDelete) {
            canDelete = [self isDecimalSymbolPressentInAmountStringValue:self.actualAmount];
        }
    }
    
    return canDelete;
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
    if ([self appendDecimalSeparatorInAmount]) {
        [self configureDisplayPanelWithActualAmount];
    }
}

- (BOOL)appendDecimalSeparatorInAmount
{
    BOOL canAppend = [self canAppendDecimalSeparator];
    if (canAppend) {
        NSString *decimalSeparator = [[IAECurrencyManager sharedManager] decimalSeparator];
        self.actualAmount = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, decimalSeparator];
    }
    
    return canAppend;
}

- (BOOL)canAppendDecimalSeparator
{
    BOOL decimalSymbolPresent = [self findDecimalRangeLocationInAmountString:self.actualAmount].location == NSNotFound ? NO : YES;
    
    return decimalSymbolPresent ? NO : self.actualAmount.length <= amountMaxNumbersLenght - 1;
}

- (IBAction)keyboardEnterPressed:(UIButton *)button
{
    [self createNewConcept];
}

- (void)createNewConcept
{
    if (self.actualAmount.length > 0) {
        IAEMonth *month = [self.dataSource monthForCalculatorViewController:self];
        IAEConcept *newConcept = [month addConceptWithAmount:[self convertToDecimalNumberKeyboardAmountValue:self.actualAmount]
                                                    category:self.actualCategory
                                                        date:[[NSDate date] timeIntervalSince1970]
                                               dayOfTheMonth:self.actualDay
                                              andDescription:@""];
        self.numberConceptsCreatedInSession++;
        [[IAEBook sharedBook] saveAll];
        
        [self resetAmountPannel];
        
        [self.delegate calculatorViewController:self didCreateNewConcept:newConcept];
    }
}

#pragma mark - Keyboard

- (void)numberPressedWithValue:(NSUInteger)value
{
    if ([self appendNewNumberToAmountWithValue:value]) {
        [self configureDisplayPanelWithActualAmount];
    }
}

- (BOOL)appendNewNumberToAmountWithValue:(NSUInteger)value
{
    NSAssert(value >= 0 && value < 10, @"");

    BOOL canAppend = [self canAppendNewNumberToAmountWithValue:value];
    if (canAppend) {
        NSString *stringValue = [[NSNumber numberWithUnsignedInteger:value] stringValue];
        self.actualAmount = [NSMutableString stringWithFormat:@"%@%@", self.actualAmount, stringValue];
    }
    
    return canAppend;
}

- (BOOL)canAppendNewNumberToAmountWithValue:(NSUInteger)value
{
    NSAssert(value >= 0 && value < 10, @"");

    BOOL withSpaceForNewNumber = [self isActualAmountWithSpaceForNewValue];
    BOOL withSpaceForDecimalNumber = [self isActualAmountWithSpaceForNewDecimalNumber];
    BOOL withValueUnderMaxAllowed = [self isActualAmountUnderMaxDecimalNumberAllowedWithNewValue:value];

    return withSpaceForNewNumber && withSpaceForDecimalNumber && withValueUnderMaxAllowed;
}

- (BOOL)isActualAmountWithSpaceForNewValue
{
    return self.actualAmount.length <= amountMaxNumbersLenght;
}

- (BOOL)isActualAmountWithSpaceForNewDecimalNumber
{
    BOOL spaceAvailable = [self characterSpaceForDecimalNumbers] > 0;
    
    return spaceAvailable;
}

- (NSUInteger)characterSpaceForDecimalNumbers
{
    NSRange decimalRange = [self findDecimalRangeLocationInAmountString:self.actualAmount];
    NSUInteger space = amountMaxNumberLenghtInDecimalPart;
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
    
    return [tmpNumberValue compare:self.maxDecimalNumberAllowed] != NSOrderedDescending;
}

- (void)configureDisplayPanelWithActualAmount
{
    NSString *amountStringToDisplay = [NSMutableString string];
    IAECurrencyManager *currencyManager = [IAECurrencyManager sharedManager];
    [currencyManager saveCurrencyFormatterFractionState];

    if (self.actualAmount.length > 0) {
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
    NSString *amountStringDisplayable = [NSMutableString stringWithString:[[IAECurrencyManager sharedManager].currencyFormatter
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
    NSUInteger maximumFractionDigits = maximumFractionDigits;
    
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

- (void)resetAmountPannel
{
    self.actualAmount = nil;
    [self configureDisplayPanelWithActualAmount];
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
    self.actualDay = 0;
    [self configureDisplayPanelWithActualDay];
}

#pragma mark - IAEDisplayCalculatorViewDelegate

- (void)amountLabelWasCleanInDisplayPanelCalculatorView:(IAEDisplayPanelCalculatorView *)displayPanelCalculatorView
{
    [self resetAmountPannel];
}


@end
