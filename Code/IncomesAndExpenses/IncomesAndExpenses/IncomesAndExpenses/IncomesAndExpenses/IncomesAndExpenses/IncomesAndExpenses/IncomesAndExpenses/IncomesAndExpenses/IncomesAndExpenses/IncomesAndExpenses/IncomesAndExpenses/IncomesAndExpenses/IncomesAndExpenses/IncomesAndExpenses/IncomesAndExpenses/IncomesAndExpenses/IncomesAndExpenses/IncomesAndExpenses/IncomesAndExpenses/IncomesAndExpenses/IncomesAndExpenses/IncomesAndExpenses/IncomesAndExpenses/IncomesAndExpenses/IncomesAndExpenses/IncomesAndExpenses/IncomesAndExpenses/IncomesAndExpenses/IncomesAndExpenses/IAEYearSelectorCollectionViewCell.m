//
//  IAEYearSelectorCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYearSelectorCollectionViewCell.h"
#import "IAEValueDecoratorView.h"
#import "IAEEconomicValueTypeHelper.h"
#import "UIView+RoundedCorners.h"
#import "IAECurrencyManager.h"
#import "IAECircleDecoratorView.h"

@interface IAEYearSelectorCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *cellContainerView;

@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *economicDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet IAECircleDecoratorView *openYearDecoratorView;

@end

@implementation IAEYearSelectorCollectionViewCell

static NSString * const kFontFamilyForYearDateLabel = @"HelveticaNeue-UltraLight";
static NSString * const kFontFamilyForBalanceLabel = @"HelveticaNeue-Italic";
static const NSUInteger kFontFamilySizeForYearDateLabel = 55;
static const NSUInteger kFontFamilySizeForBalanceLabel = 21;

static NSUInteger containerViewRoundRectSize = 10;

- (void)setShowOpenYearDecorator:(BOOL)showOpenYearDecorator
{
    if (showOpenYearDecorator != _showOpenYearDecorator) {
        _showOpenYearDecorator = showOpenYearDecorator;
    }
    
    // Nota: Lo sacamos para tener siempre sincronizado el valor
    _openYearDecoratorView.hidden = !_showOpenYearDecorator;
}

- (void)configureContainerViewRoundRects
{
    [self addRoundedCorners:UIRectCornerAllCorners withRadius:containerViewRoundRectSize];
}

#pragma mark - Public Methods

- (void)configureWithYearDate:(NSUInteger)yearDate andBalance:(NSDecimalNumber *)balance
{
    NSAssert(yearDate > 0, @"");
    
    [self configureContainerViewRoundRects];

    [self showControlsAssociatedWithConcepts:YES];
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:[self yearStringFromYearDate:yearDate]
                                                                    attributes:[self createAttributeDictionaryForYearLabelWithColor:[UIColor blackColor]]];
    self.economicDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:balance];
    NSString *balanceString = [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:balance];
    self.balanceLabel.attributedText = [[NSAttributedString alloc] initWithString:balanceString
                                                                       attributes:[self createAttributeDictionaryForBalanceYearLabel]];
}

- (void)configureWithYearDate:(NSUInteger)yearDate
{
    NSAssert(yearDate > 0, @"");
    
    [self configureContainerViewRoundRects];

    [self showControlsAssociatedWithConcepts:NO];
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:[self yearStringFromYearDate:yearDate]
                                                                    attributes:[self createAttributeDictionaryForYearLabelWithColor:[UIColor blackColor]]];
}

- (void)showControlsAssociatedWithConcepts:(BOOL)show
{
    BOOL hide = !show;
    
    self.economicDecoratorView.hidden = hide;
    self.balanceLabel.hidden = hide;
}

- (NSString *)yearStringFromYearDate:(NSUInteger)yearDate
{
    NSString *yearString = [NSString stringWithFormat:@"%d", yearDate];
    
    return yearString;
}

- (NSDictionary *)createAttributeDictionaryForYearLabelWithColor:(UIColor *)color
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyForYearDateLabel size:kFontFamilySizeForYearDateLabel],
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:20.0]};

    return attributes;
}

- (NSDictionary *)createAttributeDictionaryForBalanceYearLabel
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyForBalanceLabel size:kFontFamilySizeForBalanceLabel],
                                  NSForegroundColorAttributeName: [UIColor lightGrayColor],
                                  NSKernAttributeName: [NSNumber numberWithInteger:1.0]};
    
    return attributes;    
}

@end
