//
//  IAEDisplayPanelView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDisplayPanelCalculatorView.h"
#import "IAECurrencyManager.h"
#import "IAEColorHelper.h"
#import "IAEStrokeAnimatableLineView.h"
#import "IAEDisplayPanelCalculatorViewDelegate.h"

@interface IAEDisplayPanelCalculatorView()
@property (nonatomic, weak) UIView *categoryContainerView;
@property (nonatomic, weak) UIView *dayContainerView;
@property (nonatomic, weak) UIButton *categoryButton;
@property (nonatomic, weak) UIButton *dayButton;
@property (nonatomic, weak) UILabel *amountLabel;
@property (nonatomic, weak) UIView *helperForStrokeView;
@property (nonatomic, strong) UISwipeGestureRecognizer *swipeGestureForAmountClear;
@property (nonatomic, strong) IAEStrokeAnimatableLineView *strokeAnimatableLineView;
@end

@implementation IAEDisplayPanelCalculatorView

#pragma mark - Constants

static const NSUInteger kTagCategoryContainerView = 5;
static const NSUInteger kTagCategoryButton = 10;
static const NSUInteger kTagDayContainerView = 15;
static const NSUInteger kTagDayButton = 20;
static const NSUInteger kTagAmountLabel = 30;
static const NSUInteger kTagStrokeHelperView = 100;

static NSString * const kLtextNoCategorySelected = @"LTEXT_CALCULATOR_NOCATEGORYSELECTED";
static NSString * const kLtextNoDaySelected = @"LTEXT_CALCULATOR_NODAYSELECTED";
static NSString * const kLtextDaySelected = @"LTEXT_CALCULATOR_DAYSELECTED";

static NSString * const kFontFamilyNameForAmountLabel = @"HelveticaNeue-Thin";
static const NSUInteger kFontFamilySizeForAmountLabel = 42;
static const CGFloat kFontFamilyKernForAmountLabel = 0.0;

static const CGFloat kDurationOfTransitionWhenDayActive = 0.25;

static const CGFloat kDurationOfStrokeAnimation = 0.25;
static const CGFloat kColorWhiteComponentForStrokeAnimationForConcepts = 0.8;
static const CGFloat kColorWhiteAlphaComponentForStrokeAnimationForConcepts = 1.0;
static const StrokeType kTypeStrokeAnimationForConcepts = STROKEANIMATABLE_TYPE_THIN;

static const CGFloat kAlphaValueForAmountLabelInStrokeState = 0.1;
static const CGFloat kDelayBeforePerformActionsAfterStroke = 0.05;
static const CGFloat kDurationOfOpaqueTransitionOfAmountValueAfterStroke = 0.45;

static const CGFloat kDurationOfColorTransitionChange = 0.75;
static const CGFloat kAlphaValueForColorDisplay = 0.5;

#pragma mark - Init

- (UIView *)categoryContainerView
{
    if (!_categoryContainerView) {
        _categoryContainerView = (UIView *)[self viewWithTag:kTagCategoryContainerView];
    }
    
    return _categoryContainerView;
}

- (UIButton *)categoryButton
{
    if (!_categoryButton) {
        _categoryButton = (UIButton *)[self viewWithTag:kTagCategoryButton];
    }
    
    return _categoryButton;
}

- (UIView *)dayContainerView
{
    if (!_dayContainerView) {
        _dayContainerView = (UIButton *)[self viewWithTag:kTagDayContainerView];
    }
    
    return _dayContainerView;
}

- (UIButton *)dayButton
{
    if (!_dayButton) {
        _dayButton = (UIButton *)[self viewWithTag:kTagDayButton];
    }
    
    return _dayButton;
}

- (UILabel *)amountLabel
{
    if (!_amountLabel) {
        _amountLabel = (UILabel *)[self viewWithTag:kTagAmountLabel];
    }
    
    return _amountLabel;
}

- (IAEStrokeAnimatableLineView *)strokeAnimatableLineView
{
    if (!_strokeAnimatableLineView) {
        _strokeAnimatableLineView = [[IAEStrokeAnimatableLineView alloc] init];
        _strokeAnimatableLineView.durationOfStrokeAnimation = kDurationOfStrokeAnimation;
        _strokeAnimatableLineView.strokeColor = [UIColor colorWithWhite:kColorWhiteComponentForStrokeAnimationForConcepts
                                                                  alpha:kColorWhiteAlphaComponentForStrokeAnimationForConcepts];
        _strokeAnimatableLineView.strokeType = kTypeStrokeAnimationForConcepts;
        _strokeAnimatableLineView.delegate = self;
    }
    
    return _strokeAnimatableLineView;
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self.amountLabel removeGestureRecognizer:self.swipeGestureForAmountClear];
}

#pragma mark - Configuration

- (void)awakeFromNib
{
    [self configureControls];
}

- (void)configureControls
{
    [self configureCategory];
    [self configureDay];
    [self configureAmount];
    [self createAndconfigureSwipeGestureForAmountClear];
}

- (void)configureCategory
{
    [self setCategoryName:NSLocalizedString(kLtextNoCategorySelected, @"")];
}

- (void)configureDay
{
    [self setDay:0 withDayweekName:nil inMonthName:nil];
}

- (void)configureAmount
{
    // ...
}

- (void)createAndconfigureSwipeGestureForAmountClear
{
    self.swipeGestureForAmountClear = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureForAmountClearAction:)];
    self.swipeGestureForAmountClear.direction = UISwipeGestureRecognizerDirectionRight;
    [self.amountLabel addGestureRecognizer:self.swipeGestureForAmountClear];
}

#pragma mark - Category

- (void)setCategoryName:(NSString *)categoryName
{
    [self.categoryButton setTitle:categoryName forState:UIControlStateNormal];
}

#pragma mark - Day

- (void)showDayButton
{
    self.dayContainerView.hidden = NO;
    [UIView animateWithDuration:kDurationOfTransitionWhenDayActive animations:^{
        self.dayContainerView.alpha = 1.0;
        self.categoryContainerView.frame = CGRectMake(self.categoryContainerView.frame.origin.x,
                                                      0,
                                                      self.categoryContainerView.frame.size.width,
                                                      self.categoryContainerView.frame.size.height);
    } completion:^(BOOL finished) {
    }];
}

- (void)hideDayButton
{
    [UIView animateWithDuration:kDurationOfTransitionWhenDayActive animations:^{
        self.dayContainerView.alpha = 0.0;
        self.categoryContainerView.frame = CGRectMake(self.categoryContainerView.frame.origin.x,
                                                      self.frame.size.height / 4.0,
                                                      self.categoryContainerView.frame.size.width,
                                                      self.categoryContainerView.frame.size.height);
    } completion:^(BOOL finished) {
        self.dayContainerView.hidden = YES;
    }];
}

- (BOOL)isDayButtonVisible
{
    return !self.dayButton.hidden;
}

- (void)setDay:(NSUInteger)day withDayweekName:(NSString *)dayWeekName inMonthName:(NSString *)monthName
{
    NSString *dayName = day < 1 ? NSLocalizedString(kLtextNoDaySelected, @"") :
                                  [NSString stringWithFormat:NSLocalizedString(kLtextDaySelected, @""), day, [dayWeekName lowercaseString]];
    NSString *titleButton = [NSString stringWithFormat:@"%@. %@", monthName, dayName];
    [self.dayButton setTitle:titleButton forState:UIControlStateNormal];
}

#pragma mark - Ammount

- (void)setAmountString:(NSString *)amount
{
    NSString *amountToDisplay = amount.length > 0 ? amount : @"0";
    self.amountLabel.attributedText = [[NSAttributedString alloc] initWithString:amountToDisplay
                                                                      attributes:[self createAttributesForAmountLabel]];
}

- (NSDictionary *)createAttributesForAmountLabel
{
    UIFont *font = [UIFont fontWithName:kFontFamilyNameForAmountLabel size:kFontFamilySizeForAmountLabel];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: [NSNumber numberWithFloat:kFontFamilyKernForAmountLabel]};
    
    return attributes;
}

- (void)clearAmountString
{
    [self setAmountString:nil];
}

- (void)setDisplayWithIncomeColorUsingAnimation:(BOOL)animation
{
    [self setDisplayColor:[IAEColorHelper colorForEconomicIncomeValueWithAlpha:kAlphaValueForColorDisplay]
    withTransitionToColor:[IAEColorHelper colorForEconomicIncomeValue]
           usingAnimation:animation];
}

- (void)setDisplayExpenseColorUsingAnimation:(BOOL)animation
{
    [self setDisplayColor:[IAEColorHelper colorForEconomicExpenseValueWithAlpha:kAlphaValueForColorDisplay]
    withTransitionToColor:[IAEColorHelper colorForEconomicExpenseValue]
           usingAnimation:animation];
}

- (void)setDisplayColor:(UIColor *)color withTransitionToColor:(UIColor *)transitionColor usingAnimation:(BOOL)animation
{
    if (![self.backgroundColor isEqual:color]) {
        if (animation) {
            self.backgroundColor = transitionColor;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:kDurationOfColorTransitionChange animations:^{
                self.backgroundColor = color;
            }];
        } else {
            self.backgroundColor = color;
        }
    }
}

#pragma mark - Swipe Gesture

- (void)swipeGestureForAmountClearAction:(UISwipeGestureRecognizer *)swipeGesture
{
    [self applyStrokeToAmountLabel];
}

- (BOOL)canApplyStrokeToAmountLabel
{
    BOOL canApply = ![self.amountLabel.text isEqualToString:@"0"];
    
    return canApply;
}

- (void)applyStrokeToAmountLabel
{
    if ([self canApplyStrokeToAmountLabel]) {
        [self makeAndVinculeHelperViewToStrokeLabel];
        [self.strokeAnimatableLineView doStrokeOverTheView:self.helperForStrokeView];
        [UIView animateWithDuration:kDurationOfStrokeAnimation animations:^{
            self.amountLabel.alpha = kAlphaValueForAmountLabelInStrokeState;
        }];
    }
}

- (void)makeAndVinculeHelperViewToStrokeLabel
{
    CGSize textSize = [self.amountLabel.text sizeWithAttributes:[self.amountLabel.attributedText attributesAtIndex:0 effectiveRange:NULL]];
    CGRect frameOfHelperView = CGRectMake(self.amountLabel.frame.origin.x + self.amountLabel.bounds.size.width - textSize.width,
                                          self.amountLabel.frame.origin.y,
                                          textSize.width,
                                          self.amountLabel.bounds.size.height);
    UIView *helperView = [[UIView alloc] initWithFrame:frameOfHelperView];
    helperView.clipsToBounds = YES;
    helperView.backgroundColor = [UIColor clearColor];
    [self addSubview:helperView];
    self.helperForStrokeView = helperView;
}

#pragma mark - StrokeAnimatableView

- (void)strokeAnimatableView:(IAEStrokeAnimatableLineView *)strokeAnimatableView didStrokeOverTheView:(UIView *)view
{
    [self performSelector:@selector(resetStatesAndNotifyToDelegateAfterStrokeTheAmountValue)
               withObject:nil
               afterDelay:kDelayBeforePerformActionsAfterStroke];
}

- (void)resetStatesAndNotifyToDelegateAfterStrokeTheAmountValue
{
    [self.helperForStrokeView removeFromSuperview];
    [self.strokeAnimatableLineView resetStroke];
    self.strokeAnimatableLineView.alpha = 1;
    if ([self.delegate respondsToSelector:@selector(amountLabelWasCleanInDisplayPanelCalculatorView:)]) {
        [self.delegate amountLabelWasCleanInDisplayPanelCalculatorView:self];
    }
    
    [UIView animateWithDuration:kDurationOfOpaqueTransitionOfAmountValueAfterStroke animations:^{
        self.amountLabel.alpha = 1;
    }];
}



@end
