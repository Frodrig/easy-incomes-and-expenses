//
//  IAEDisplayPanelView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDisplayPanelCalculatorView.h"
#import "IAECurrencyManager.h"

@interface IAEDisplayPanelCalculatorView()
@property (nonatomic, weak) UIView *categoryContainerView;
@property (nonatomic, weak) UIView *dayContainerView;
@property (nonatomic, weak) UIButton *categoryButton;
@property (nonatomic, weak) UIButton *dayButton;
@property (nonatomic, weak) UILabel *amountLabel;
@end

@implementation IAEDisplayPanelCalculatorView

static const NSUInteger tagCategoryContainerView = 5;
static const NSUInteger tagCategoryButton = 10;
static const NSUInteger tagDayContainerView = 15;
static const NSUInteger tagDayButton = 20;
static const NSUInteger tagAmountLabel = 30;

static NSString * const fontFamilyNameForAmountLabel = @"HelveticaNeue-Ultralight";
static const NSUInteger fontFamilySizeForAmountLabel = 42;
static const CGFloat fontFamilyKernForAmountLabel = 0.0;

static const CGFloat kDurationOfTransitionWhenDayActive = 0.25;

#pragma mark - Init

- (UIView *)categoryContainerView
{
    if (!_categoryContainerView) {
        _categoryContainerView = (UIView *)[self viewWithTag:tagCategoryContainerView];
    }
    
    return _categoryContainerView;
}

- (UIButton *)categoryButton
{
    if (!_categoryButton) {
        _categoryButton = (UIButton *)[self viewWithTag:tagCategoryButton];
    }
    
    return _categoryButton;
}

- (UIView *)dayContainerView
{
    if (!_dayContainerView) {
        _dayContainerView = (UIButton *)[self viewWithTag:tagDayContainerView];
    }
    
    return _dayContainerView;
}

- (UIButton *)dayButton
{
    if (!_dayButton) {
        _dayButton = (UIButton *)[self viewWithTag:tagDayButton];
    }
    
    return _dayButton;
}

- (UILabel *)amountLabel
{
    if (!_amountLabel) {
        _amountLabel = (UILabel *)[self viewWithTag:tagAmountLabel];
    }
    
    return _amountLabel;
}

- (void)awakeFromNib
{
    [self configureControls];
}

- (void)configureControls
{
    [self configureCategory];
    [self configureDay];
    [self configureAmount];
}

- (void)configureCategory
{
    [self setCategoryName:NSLocalizedString(@"LTEXT_CALCULATOR_NOCATEGORYSELECTED", @"")];
}

- (void)configureDay
{
    [self setDay:0 withDayweekName:nil inMonthName:nil];
}

- (void)configureAmount
{
    // ...
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
    NSString *dayName = day < 1 ? NSLocalizedString(@"LTEXT_CALCULATOR_NODAYSELECTED", @"") :
                                  [NSString stringWithFormat:NSLocalizedString(@"LTEXT_CALCULATOR_DAYSELECTED", @""), day, dayWeekName];
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
    UIFont *font = [UIFont fontWithName:fontFamilyNameForAmountLabel size:fontFamilySizeForAmountLabel];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor blackColor],
                                 NSKernAttributeName: [NSNumber numberWithFloat:fontFamilyKernForAmountLabel]};
    
    return attributes;
}

- (void)clearAmountString
{
    
}


@end
