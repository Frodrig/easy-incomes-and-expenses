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
#import "IAENumberFormatterManager.h"
#import "IAECircleDecoratorView.h"
#import "IAELocalizerPhraseComposer.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEDateHelper.h"

@interface IAEYearSelectorCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *cellContainerView;

@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *economicDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UILabel *balanceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfConceptsLabel;
@property (weak, nonatomic) IBOutlet IAECircleDecoratorView *openYearDecoratorView;

@end

@implementation IAEYearSelectorCollectionViewCell

static NSString * const kFontFamilyForYearDateLabel = @"HelveticaNeue-UltraLight";
static const CGFloat kKernForYearDateLabel = 10.0;
static const NSUInteger kFontFamilySizeForYearDateLabel = 55;
static const CGFloat kColorWhiteValueForYearDateLabel = 0.0;
static const CGFloat kColorAlphaValueForYearDateLabel = 1.0;

static const CGFloat kDurationOfStrokeAnimation = 0.20;
static const CGFloat kAlphaOfStrokeAnimation = 0.25;

static const NSUInteger kContainerViewRoundRectSize = 10;

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
    [self addRoundedCorners:UIRectCornerAllCorners withRadius:kContainerViewRoundRectSize];
}

#pragma mark - Public Methods

- (void)configureWithYearDate:(NSUInteger)yearDate balance:(NSDecimalNumber *)balance andNumberOfConcepts:(NSUInteger)numberOfConcepts
{
    [self configureBasicInformationWithYearDate:yearDate andShowingControlsAssociatedWithConcepts:YES];
    self.economicDecoratorView.economicValueType = [IAEEconomicValueTypeHelper economicValueTypeFromEconomicValue:balance];
    self.balanceLabel.text = [[IAENumberFormatterManager sharedManager].currencyFormatter stringFromNumber:balance];
    self.numberOfConceptsLabel.text = [IAELocalizerPhraseComposer stringPhraseWithNumberOfConcepts:numberOfConcepts];
}

- (void)configureWithYearDate:(NSUInteger)yearDate
{
    [self configureBasicInformationWithYearDate:yearDate andShowingControlsAssociatedWithConcepts:NO];
}

- (void)configureBasicInformationWithYearDate:(NSUInteger)yearDate andShowingControlsAssociatedWithConcepts:(BOOL)showControlsForConcepts
{
    NSAssert(yearDate > 0, @"");

    [self configureContainerViewRoundRects];
    [self showControlsAssociatedWithConcepts:showControlsForConcepts];
    self.yearLabel.attributedText = [[NSAttributedString alloc] initWithString:[self yearStringFromYearDate:yearDate]
                                                                    attributes:[self createAttributeDictionaryForYearLabel]];
}

- (void)showControlsAssociatedWithConcepts:(BOOL)show
{
    BOOL hide = !show;
    
    self.economicDecoratorView.hidden = hide;
    self.balanceLabel.hidden = hide;
    self.numberOfConceptsLabel.hidden = hide;
}

- (NSString *)yearStringFromYearDate:(NSUInteger)yearDate
{
    NSString *yearString = [IAEDateHelper createYearIdentificationTagFromYearDate:yearDate withShortForm:YES];
    
    return yearString;
}

- (NSDictionary *)createAttributeDictionaryForYearLabel
{
    NSDictionary *attributes =  @{NSFontAttributeName: [UIFont fontWithName:kFontFamilyForYearDateLabel size:kFontFamilySizeForYearDateLabel],
                                  NSForegroundColorAttributeName: [UIColor colorWithWhite:kColorWhiteValueForYearDateLabel alpha:kColorAlphaValueForYearDateLabel],
                                  NSKernAttributeName: [NSNumber numberWithInteger:kKernForYearDateLabel]};

    return attributes;
}

- (void)goToStrokeModeWithAnimation:(BOOL)animation
{
    if (![self inStrokeMode]) {
        _inStrokeMode = YES;
        [self strokeModeActive:YES withAnimation:animation];
    }
}

- (void)exitFromStrokeModeWithAnimation:(BOOL)animation
{
    if ([self inStrokeMode]) {
        _inStrokeMode = NO;
        [self strokeModeActive:NO withAnimation:animation];
    }
}

- (void)strokeModeActive:(BOOL)active withAnimation:(BOOL)animation
{
    CGFloat alphaValue = active ? kAlphaOfStrokeAnimation : 1;
    [UIView animateWithDuration:animation ? kDurationOfStrokeAnimation : 0 animations:^{
        self.yearLabel.alpha = alphaValue;
        self.balanceLabel.alpha = alphaValue;
        self.numberOfConceptsLabel.alpha = alphaValue;
        self.openYearDecoratorView.alpha = alphaValue;
        self.economicDecoratorView.alpha = alphaValue;
    } completion:^(BOOL finished) {
        
    }];
}

@end
