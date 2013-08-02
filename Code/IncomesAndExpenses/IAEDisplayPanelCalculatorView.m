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
@property (nonatomic, weak) UIButton *categoryButton;
@property (nonatomic, weak) UIButton *dayButton;
@property (nonatomic, weak) UILabel *amountLabel;
@end

@implementation IAEDisplayPanelCalculatorView

static NSUInteger tagCategoryButton = 10;
static NSUInteger tagDayButton = 20;
static NSUInteger tagAmountLabel = 30;

static NSString * const fontFamilyNameForAmountLabel = @"HelveticaNeue-Light";
static NSUInteger fontFamilySizeForAmountLabel = 17;
static CGFloat fontFamilyKernForAmountLabel = 0.0;

#pragma mark - Init

- (UIButton *)categoryButton
{
    if (!_categoryButton) {
        _categoryButton = (UIButton *)[self viewWithTag:tagCategoryButton];
    }
    
    return _categoryButton;
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
    [self setDay:0];
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
    self.dayButton.hidden = NO;
}

- (void)hideDayButton
{
    self.dayButton.hidden = YES;
}

- (BOOL)isDayButtonVisible
{
    return !self.dayButton.hidden;
}

- (void)setDay:(NSUInteger)day
{
    NSString *dayName = day < 1 ? NSLocalizedString(@"LTEXT_CALCULATOR_NODAYSELECTED", @"") : [NSNumber numberWithUnsignedInteger:day].stringValue;
    [self.dayButton setTitle:dayName forState:UIControlStateNormal];
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
