//
//  IAEEditModeConceptCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEValueDecoratorView.h"
#import "UIView+DrawBottomLine.m"
#import "NSNumber+DefaultValues.h"

@interface IAEEditModeConceptCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *identifierContainerView;

@end

@implementation IAEEditModeConceptCollectionViewCell

static NSUInteger tagForEntryInstantLabelOfIdentifierContainerView = 10;
static NSUInteger tagForDayIndexLabelOfIdentifierContainerView = 20;
static NSUInteger tagForDayOfTheWeekNameLabelOfIdentifierContainerView = 30;
static NSUInteger tagForNoDayLabelOfIdentifierContainerVew = 40;

static NSString  * const entryInstantFontFamilyName = @"HelveticaNeue-Bold";
static CGFloat entryInstantFontFamilySize = 66;
static NSString * const entryWithNoDayFontFamilyName = @"HelveticaNeue";
static CGFloat entryWithNoDayFontFamilySize = 17;

static NSString * const ltexForEntryWithNoDay = @"LTEXT_EDITMODECONCEPTCELL_ENTRYWITHNODAY";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawBottomDotLine];
}

// Esto va en otra clase como, por ejemplo, un configurador
#pragma mark - EntryIdentifierConfiguration

- (void)setIdentifierWithEntryInstantIndex:(NSUInteger)index
{
    if ([self removeIdentifierContainerViewSubviewsIfNotConfiguredWithEntryInstantIndex]) {
        [self createAndAddInIdentifierContainerViewEntryInstantLabel];
    }
    
    [self configureEntryInstantLabelWithIndex:index];
}

- (void)setIdentifierWithDayOfTheMonthIndex:(NSUInteger)index andDayOfTheWeekName:(NSString *)name
{
    if ([self removeIdentifierContainerViewSubviewsIfNotConfiguredWithDay]) {
        [self createAndAddInIdentifierContainerViewDayLabels];
    }
    
    [self configureDayLabelsWithDayOfTheMonthIndex:index andDayOfTheWeekName:name];
}

- (void)setIdentifierWithoutDay
{
    if ([self removeIdentifierContainerViewSubviewsIfNotConfiguredWithNoDay]) {
        [self createAndAddIdentifierWithoutDay];
    }
    
    [self configureNoDayLabel];
}

- (BOOL)removeIdentifierContainerViewSubviewsIfNotConfiguredWithEntryInstantIndex
{
    BOOL remove = ![self isContainerViewConfiguredWithEntryInstantIndex];
    if (remove) {
        [self removeIdentifierContainerViewSubviews];
    }
    
    return remove;
}

- (BOOL)removeIdentifierContainerViewSubviewsIfNotConfiguredWithDay
{
    BOOL remove = ![self isContainerViewConfiguredWithDay];
    if (remove) {
        [self removeIdentifierContainerViewSubviews];
    }
    
    return remove;
}

- (BOOL)removeIdentifierContainerViewSubviewsIfNotConfiguredWithNoDay
{
    BOOL remove = ![self isContainerViewConfiguredWithNoDay];
    
    if (remove) {
        [self removeIdentifierContainerViewSubviews];
    }
    
    return remove;
}

- (BOOL)isContainerViewConfiguredWithEntryInstantIndex
{
    return [self.identifierContainerView viewWithTag:tagForEntryInstantLabelOfIdentifierContainerView] != nil;
}

- (BOOL)isContainerViewConfiguredWithDay
{
    return ([self.identifierContainerView viewWithTag:tagForDayIndexLabelOfIdentifierContainerView] != nil &&
            [self.identifierContainerView viewWithTag:tagForDayOfTheWeekNameLabelOfIdentifierContainerView] != nil);
}

- (BOOL)isContainerViewConfiguredWithNoDay
{
    return ([self.identifierContainerView viewWithTag:tagForNoDayLabelOfIdentifierContainerVew] != nil);
}

- (void)removeIdentifierContainerViewSubviews
{
    while(self.identifierContainerView.subviews.count > 0) {
        UIView *subview = [self.identifierContainerView.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)createAndAddInIdentifierContainerViewEntryInstantLabel
{
    UILabel *label = [self createEmptyDefaultLabelWithRect:self.identifierContainerView.bounds
                                                       tag:tagForEntryInstantLabelOfIdentifierContainerView
                                          andNumberOfLines:1];
    [self.identifierContainerView addSubview:label];
}

- (UILabel *)createEmptyDefaultLabelWithRect:(CGRect)rect tag:(NSUInteger)tag andNumberOfLines:(NSUInteger)numberOfLines
{
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.tag = tag;
    label.textAlignment = NSTextAlignmentCenter;
    label.numberOfLines = numberOfLines;
    label.backgroundColor = [UIColor clearColor];
    [label setMinimumScaleFactor:0.5];
    
    return label;
}

- (void)configureEntryInstantLabelWithIndex:(NSUInteger)index
{
    NSString *text = [NSString stringWithFormat:@"%d", index];
    UIFont *font = [UIFont fontWithName:entryInstantFontFamilyName size:entryInstantFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.9 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInteger:0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:tagForEntryInstantLabelOfIdentifierContainerView];
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    [label sizeToFit];
}

- (void)createAndAddInIdentifierContainerViewDayLabels
{
    // ....
}

- (void)configureDayLabelsWithDayOfTheMonthIndex:(NSUInteger)dayOfTheMonthIndex andDayOfTheWeekName:(NSString *)dayOfTheWeekName
{
    // ...
}

- (void)createAndAddIdentifierWithoutDay
{
    UILabel *label = [self createEmptyDefaultLabelWithRect:self.identifierContainerView.bounds
                                                       tag:tagForNoDayLabelOfIdentifierContainerVew
                                          andNumberOfLines:2];
    [self.identifierContainerView addSubview:label];
}

- (void)configureNoDayLabel
{
    NSString *text = NSLocalizedString(ltexForEntryWithNoDay, @"");
    UIFont *font = [UIFont fontWithName:entryWithNoDayFontFamilyName size:entryWithNoDayFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInt:0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:tagForNoDayLabelOfIdentifierContainerVew];
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


@end
