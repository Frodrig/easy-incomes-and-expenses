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
#import "IAENumberFormatterManager.h"
#import "IAEColorHelper.h"
#import "IAEAnimateValueUpdater.h"
#import "IAEEconomicValueTypeHelper.h"

@interface IAEContextView()

@property(nonatomic, weak) UIView *contentView;

@end

@implementation IAEContextView

static const NSUInteger kTagViewContentName = 10;
static const NSUInteger kTagViewBalance = 20;

static const CGFloat kTimeAnimationBalanceUpdate = 1.5;

static NSString * const kXibContentViewContentName = @"IAEContextViewContent";

static NSString * const kFontFamilyName = @"HelveticaNeue-UltraLight";
static const NSUInteger kSizeFontForNameLabel = 56;
static const CGFloat kKernForNameLabel = 10;
static const NSUInteger kSizeFontForBalanceLabel = 73;
static const CGFloat kKernForBalanceLabel = 4;

- (UILabel *)contentBalanceLabel
{
    return (UILabel *)[self viewWithTag:kTagViewBalance];
}

- (UILabel *)contentNameLabel
{
    return (UILabel *)[self viewWithTag:kTagViewContentName];
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
    _contentView = [UIView viewFromXib:kXibContentViewContentName withOwner:self];
    [self addSubview:_contentView];
}

- (void)prepareLabelsOfBalanceItem
{
    [self vinculeLabelsOfBalanceItemAsProperties];
}

- (void)vinculeLabelsOfBalanceItemAsProperties
{
    _contentNameLabel = (UILabel *)[_contentView viewWithTag:kTagViewContentName];
    _contentBalanceLabel = (UILabel *)[_contentView viewWithTag:kTagViewBalance];
}

- (void)reloadDataWithoutAnimation
{
    [self configureContentNameLabelText];
    NSString *balanceString = [self balanceStringValueForUpdateWithoutUsingAnimation];
    [self configureContentBalanceLabelText:NO fromBalanceStringValue:balanceString];
}

- (NSString *)balanceStringValueForUpdateWithoutUsingAnimation
{
    NSString *balanceString = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:[self contentBalance]];
    
    return balanceString;
}

- (void)reloadDataWithAnimationFromUsingZeroValue:(BOOL)fromZero
{
    [self configureContentNameLabelText];
    NSString *balanceString = [self balanceStringValueForUpdateUsingAnimationFromZeroValue:fromZero];
    [self configureContentBalanceLabelText:YES fromBalanceStringValue:balanceString];
}

- (NSString *)balanceStringValueForUpdateUsingAnimationFromZeroValue:(BOOL)fromZero
{
    NSString *balanceString = fromZero ? [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:[NSDecimalNumber zero]] :
                                         self.contentBalanceLabel.text;

    return balanceString;
}

- (void)configureContentNameLabelText
{
    NSString *contentName = [self contentName];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:kSizeFontForNameLabel
                                                                          color:[UIColor blackColor]
                                                                     andKerning:kKernForNameLabel];
    
    self.contentNameLabel.attributedText = [[NSAttributedString alloc] initWithString:contentName attributes:attributes];
}

- (void)configureContentBalanceLabelText:(BOOL)animation fromBalanceStringValue:(NSString *)balanceStringValue
{
    NSDecimalNumber *contentBalance = [self contentBalance];
    
    EconomicValueType economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:contentBalance];
    UIColor *labelColor = [IAEColorHelper colorForEconomicValueType:economicValueType];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:kSizeFontForBalanceLabel
                                                                          color:labelColor
                                                                     andKerning:kKernForBalanceLabel];
    self.contentBalanceLabel.attributedText = [[NSAttributedString alloc] initWithString:balanceStringValue attributes:attributes];
    
    if (animation) {
        [[IAEAnimateValueUpdater defaultAnimateValueUpdater] processEconomicLabel:self.contentBalanceLabel
                                                                            toValue:contentBalance
                                                                       withDuration:kTimeAnimationBalanceUpdate];
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
    NSString *contentBalanceString = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:contentBalance];
    
    return contentBalanceString;
}

- (NSDecimalNumber *)contentBalance
{
    NSDecimalNumber *contentBalance = [self.dataSource balanceForContextView:self];
    
    return contentBalance;
}

- (NSDictionary *)createAttributeDictionaryForLabelsWithSize:(CGFloat)size color:(UIColor *)color andKerning:(CGFloat)kerning
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:kerning]};
    
    return attributes;
}


@end
