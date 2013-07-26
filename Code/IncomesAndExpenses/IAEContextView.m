//
//  IAEContextView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEContextView.h"
#import "IAEContextViewDataSource.h"
#import "UIView+LoadFromXib.h"
#import "IAECurrencyManager.h"
#import "IAEColorHelper.h"
#import "IAEEconomicValueUpdater.h"
#import "IAEEconomicValueTypeHelper.h"

@interface IAEContextView()

@property(nonatomic, weak) UIView *contentView;
@property(nonatomic, weak) UILabel *contentNameLabel;
@property(nonatomic, weak) UILabel *contentBalanceLabel;

@end

@implementation IAEContextView

static NSUInteger tagViewContentName = 10;
static NSUInteger tagViewBalance = 20;

static CGFloat timeAnimationBalanceUpdate = 1.55;

static NSString * const xibContentViewContentName = @"IAEContextViewContent";

static NSString * const fontFamilyName = @"HelveticaNeue-UltraLight";
static NSUInteger sizeFontForNameLabel = 73;
static NSUInteger sizeFontForBalanceLabel = 59;

- (UILabel *)contentBalanceLabel
{
    return (UILabel *)[self viewWithTag:tagViewBalance];
}

- (UILabel *)contentNameLabel
{
    return (UILabel *)[self viewWithTag:tagViewContentName];
}

- (id)initWithFrame:(CGRect)frame type:(IAEContextViewType)contextViewType andValueIndex:(NSUInteger)valueIndex
{
    self = [super initWithFrame:frame];
    if (self) {
        _contextType = contextViewType;
        _valueIndex = valueIndex;
        [self loadAndAddEditModeBalanceItem];
        [self prepareLabelsOfBalanceItem];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"usar initWithFrame:type:andValueIndex:");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(0, @"usar initWithFrame:type:andValueIndex:");
    return nil;
}

- (void)loadAndAddEditModeBalanceItem
{
    _contentView = [UIView viewFromXib:xibContentViewContentName withOwner:self];
    [self addSubview:_contentView];
}

- (void)prepareLabelsOfBalanceItem
{
    [self vinculeLabelsOfBalanceItemAsProperties];
}

- (void)vinculeLabelsOfBalanceItemAsProperties
{
    _contentNameLabel = (UILabel *)[_contentView viewWithTag:tagViewContentName];
    _contentBalanceLabel = (UILabel *)[_contentView viewWithTag:tagViewBalance];
}

- (void)reloadDataWithAnimation:(BOOL)animation
{
    [self configureContentNameLabelText:animation];
    [self configureContentBalanceLabelText:animation];
}

- (void)configureContentNameLabelText:(BOOL)animation
{
    NSString *contentName = [self contentName];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:sizeFontForNameLabel color:[UIColor blackColor] andKerning:15];
    
    self.contentNameLabel.attributedText = [[NSAttributedString alloc] initWithString:contentName attributes:attributes];
}

- (void)configureContentBalanceLabelText:(BOOL)animation
{
    NSDecimalNumber *contentBalance = [self contentBalance];
    NSString *contentBalanceString = animation ? self.contentNameLabel.text : [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:contentBalance];
    UIColor *labelColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:contentBalance]];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:sizeFontForBalanceLabel color:labelColor andKerning:0];
    
    self.contentBalanceLabel.attributedText = [[NSAttributedString alloc] initWithString:contentBalanceString attributes:attributes];
    
    if (animation) {
        [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:self.contentBalanceLabel
                                                                            toValue:contentBalance
                                                                       withDuration:timeAnimationBalanceUpdate];
    }
}

- (NSString *)contentName
{
    NSString *contentName = [self.dataSource nameForContextView:self];
    
    return contentName;
}

- (NSString *)contentBalanceString
{
    NSDecimalNumber *contentBalance = [self contentBalance];
    NSString *contentBalanceString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:contentBalance];
    
    return contentBalanceString;
}

- (NSDecimalNumber *)contentBalance
{
    NSDecimalNumber *contentBalance = [self.dataSource balanceForContextView:self];
    
    return contentBalance;
}

- (NSDictionary *)createAttributeDictionaryForLabelsWithSize:(CGFloat)size color:(UIColor *)color andKerning:(CGFloat)kerning
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:fontFamilyName size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:kerning]};
    
    return attributes;
}


@end
