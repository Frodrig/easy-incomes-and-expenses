//
//  IAEEditModeMonthBalanceView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeMonthBalanceView.h"
#import "IAEEditModeMonthBalanceViewDataSource.h"
#import "UIView+LoadFromXib.h"
#import "IAECurrencyManager.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueUpdater.h"
#import "IAEEconomicValueTypeHelper.h"

#define VIEWTAG_MONTHNAMELABEL     10
#define VIEWTAG_MONTHBALANCE_LABEL 20

@interface IAEEditModeMonthBalanceView()

@property(nonatomic) NSUInteger monthIndex;
@property(nonatomic, weak) UIView *editModeBalanceItem;
@property(nonatomic, weak) UILabel *monthNameLabel;
@property(nonatomic, weak) UILabel *monthBalanceLabel;

@end

@implementation IAEEditModeMonthBalanceView

static CGFloat timeBalanceUpdateAnimation = 1.55;

- (UILabel *)monthBalanceLabel
{
    return (UILabel *)[self viewWithTag:VIEWTAG_MONTHBALANCE_LABEL];
}

- (UILabel *)monthNameLabel
{
    return (UILabel *)[self viewWithTag:VIEWTAG_MONTHNAMELABEL];
}

- (id)initWithFrame:(CGRect)frame andMonthIndex:(NSUInteger)monthIndex;
{
    self = [super initWithFrame:frame];
    if (self) {
        _monthIndex = monthIndex;
        [self loadAndAddEditModeBalanceItem];
        [self prepareLabelsOfBalanceItem];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"usar initWithFrame:andMonthIndex");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(0, @"usar initWithFrame:andMonthIndex");
    return nil;
}

- (void)loadAndAddEditModeBalanceItem
{
    _editModeBalanceItem = [UIView viewFromXib:@"IAEEditModeMonthBalanceItem" withOwner:self];
    
    [self addSubview:_editModeBalanceItem];
}

- (void)prepareLabelsOfBalanceItem
{
    [self vinculeLabelsOfBalanceItemAsProperties];
}

- (void)vinculeLabelsOfBalanceItemAsProperties
{
    _monthNameLabel = (UILabel *)[_editModeBalanceItem viewWithTag:VIEWTAG_MONTHNAMELABEL];
    _monthBalanceLabel = (UILabel *)[_editModeBalanceItem viewWithTag:VIEWTAG_MONTHBALANCE_LABEL];
}

- (void)reloadDataWithAnimation:(BOOL)animation
{
    [self configureMonthNameLabelText:animation];
    [self configureMonthBalanceLabelText:animation];
}

- (void)configureMonthNameLabelText:(BOOL)animation
{
    NSString *monthName = [self monthName];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:73 color:[UIColor blackColor] andKerning:15];
    
    self.monthNameLabel.attributedText = [[NSAttributedString alloc] initWithString:monthName attributes:attributes];
}

- (void)configureMonthBalanceLabelText:(BOOL)animation
{
    NSDecimalNumber *monthBalance = [self monthBalance];
    NSString *monthBalanceString = animation ? self.monthBalanceLabel.text : [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:monthBalance];
    UIColor *labelColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:monthBalance]];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:59 color:labelColor andKerning:0];
   
    self.monthBalanceLabel.attributedText = [[NSAttributedString alloc] initWithString:monthBalanceString attributes:attributes];

    if (animation) {
        [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:self.monthBalanceLabel
                                                                            toValue:monthBalance
                                                                       withDuration:timeBalanceUpdateAnimation];
    }
}

- (NSString *)monthName
{
    NSString *monthName = [self.dataSource editModeMonthBalanceView:self monthNameForMonthWithIndex:self.monthIndex];
 
    return monthName;
}

- (NSString *)monthBalanceString
{
    NSDecimalNumber *monthBalance = [self monthBalance];
    NSString *monthBalanceString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:monthBalance];

    return monthBalanceString;
}

- (NSDecimalNumber *)monthBalance
{
    NSDecimalNumber *monthBalance = [self.dataSource editModeMonthBalanceView:self monthBalanceForMonthWithIndex:self.monthIndex];

    return monthBalance;
}

- (NSDictionary *)createAttributeDictionaryForLabelsWithSize:(CGFloat)size color:(UIColor *)color andKerning:(CGFloat)kerning
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:kerning]};
    
    return attributes;
}






@end
