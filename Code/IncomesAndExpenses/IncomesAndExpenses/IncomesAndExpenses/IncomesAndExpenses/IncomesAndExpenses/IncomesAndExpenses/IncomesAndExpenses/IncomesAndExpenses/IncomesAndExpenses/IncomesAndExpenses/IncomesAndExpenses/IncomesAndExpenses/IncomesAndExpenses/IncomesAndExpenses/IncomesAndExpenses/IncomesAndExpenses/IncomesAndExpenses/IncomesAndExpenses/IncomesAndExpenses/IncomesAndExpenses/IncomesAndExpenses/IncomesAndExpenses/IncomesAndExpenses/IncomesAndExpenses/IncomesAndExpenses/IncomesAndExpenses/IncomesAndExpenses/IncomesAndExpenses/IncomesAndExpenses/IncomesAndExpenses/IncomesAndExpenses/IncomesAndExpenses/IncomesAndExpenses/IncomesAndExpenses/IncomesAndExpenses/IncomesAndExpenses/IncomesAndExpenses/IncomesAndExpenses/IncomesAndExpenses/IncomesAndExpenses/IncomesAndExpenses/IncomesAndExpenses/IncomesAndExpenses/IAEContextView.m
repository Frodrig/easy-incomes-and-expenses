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

static const NSUInteger kTagViewContentName = 10;
static const NSUInteger kTagViewBalance = 20;

static const CGFloat kTimeAnimationBalanceUpdate = 1.55;

static NSString * const kXibContentViewContentName = @"IAEContextViewContent";

static NSString * const kFontFamilyName = @"HelveticaNeue-UltraLight";
static const NSUInteger kSizeFontForNameLabel = 56;
static const CGFloat kKernForNameLabel = 20;
static const NSUInteger kSizeFontForBalanceLabel = 73;
static const CGFloat kKernForBalanceLabel = 5;

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

- (void)reloadDataWithAnimation:(BOOL)animation
{
    [self configureContentNameLabelText:animation];
    [self configureContentBalanceLabelText:animation];
}

- (void)configureContentNameLabelText:(BOOL)animation
{
    NSString *contentName = [self contentName];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:kSizeFontForNameLabel
                                                                          color:[UIColor blackColor]
                                                                     andKerning:kKernForNameLabel];
    
    self.contentNameLabel.attributedText = [[NSAttributedString alloc] initWithString:contentName attributes:attributes];
}

- (void)configureContentBalanceLabelText:(BOOL)animation
{
    NSDecimalNumber *contentBalance = [self contentBalance];
    NSString *contentBalanceString = animation ? self.contentBalanceLabel.text : [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:contentBalance];
    UIColor *labelColor = [IAEColorHelper colorForEconomicValueType:[IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:contentBalance]];
    NSDictionary *attributes = [self createAttributeDictionaryForLabelsWithSize:kSizeFontForBalanceLabel
                                                                          color:labelColor
                                                                     andKerning:kKernForBalanceLabel];
    
    self.contentBalanceLabel.attributedText = [[NSAttributedString alloc] initWithString:contentBalanceString attributes:attributes];
    
    if (animation) {
        [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:self.contentBalanceLabel
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
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyName size:size],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:kerning]};
    
    return attributes;
}


@end
