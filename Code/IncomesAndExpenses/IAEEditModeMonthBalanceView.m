//
//  IAEEditModeMonthBalanceView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 02/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeMonthBalanceView.h"
#import "UIView+LoadFromXib.h"
#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAECurrencyManager.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueTypeHelper.h"

#define VIEWTAG_MONTHNAMELABEL     10
#define VIEWTAG_MONTHBALANCE_LABEL 20

@interface IAEEditModeMonthBalanceView()

@property(nonatomic) NSUInteger monthIndex;
@property(nonatomic, weak) UIView *editModeBalanceItem;
@property(nonatomic, weak) UILabel *monthNameLabel;

@end

@implementation IAEEditModeMonthBalanceView

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
    [self configureMonthLabelsText];
}

- (void)vinculeLabelsOfBalanceItemAsProperties
{
    _monthNameLabel = (UILabel *)[_editModeBalanceItem viewWithTag:VIEWTAG_MONTHNAMELABEL];
    _monthBalanceLabel = (UILabel *)[_editModeBalanceItem viewWithTag:VIEWTAG_MONTHBALANCE_LABEL];
}

- (void)configureMonthLabelsText
{
    [self configureMonthNameLabelText];
    [self configureMonthBalanceLabelText];
}

- (void)configureMonthNameLabelText
{
    NSString *monthName = [self monthName];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:73 color:[UIColor blackColor] andKerning:15];
    
    _monthNameLabel.attributedText = [[NSAttributedString alloc] initWithString:monthName attributes:attributes];
}

- (void)configureMonthBalanceLabelText
{
    NSDecimalNumber *monthBalance = [self monthBalance];
    NSString *monthBalanceString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:monthBalance];
    UIColor *labelColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:monthBalance]];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:59 color:labelColor andKerning:0];
    
    _monthBalanceLabel.attributedText = [[NSAttributedString alloc] initWithString:monthBalanceString attributes:attributes];
}

- (NSString *)monthName
{
    IAEMonth *month = [self month];
    return [month description];
}

- (NSString *)monthBalanceString
{
    IAEMonth *month = [self month];
    NSString *balance = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[month balance]];
    
    return balance;
}

- (NSDecimalNumber *)monthBalance
{
    IAEMonth *month = [self month];
    return [month balance];
}

- (IAEMonth *)month
{
    IAEYear *year = [self year];
    return [year.ordererMonths objectAtIndex:_monthIndex];
}

- (IAEYear *)year
{
    return [[IAEBook sharedBook] findActualYear];
}

- (NSDictionary *)createAttributeDictionaryForLabelsWithSize:(CGFloat)size color:(UIColor *)color andKerning:(CGFloat)kerning
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:kerning]};
    
    return attributes;
}






@end
