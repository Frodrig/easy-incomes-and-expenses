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
#import "NSString+TwoDigitString.h"

@interface IAEEditModeConceptCollectionViewCell()

@end

@implementation IAEEditModeConceptCollectionViewCell

static const NSUInteger kTagForEntryInstantLabelOfIdentifierContainerView = 10;
static const NSUInteger kTagForDayIndexLabelOfIdentifierContainerView = 20;
static const NSUInteger kTagForNoDayLabelOfIdentifierContainerVew = 30;

static NSString  * const kEntryInstantFontFamilyName = @"HelveticaNeue-Bold";
static const CGFloat kEntryInstantFontFamilySize = 66;
static NSString * const kEntryWithNoDayFontFamilyName = @"HelveticaNeue";
static const CGFloat kEntryWithNoDayFontFamilySize = 17;
static NSString * const kEntryDayOfTheMonthFontFamilyName = @"HelveticaNeue";
static const CGFloat kEntryDayOfTheMonthFontFamilySize = 24;

static NSString * const kLTexForEntryWithNoDay = @"LTEXT_EDITMODECONCEPTCELL_ENTRYWITHNODAY";

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

#pragma mark - Location Test

- (BOOL)isAmountLabelContainingLocationPoint:(CGPoint)location
{
    return CGRectContainsPoint(self.amountLabel.frame, location);
}

- (BOOL)isCategoryNameOrTypeContainingLocationPoint:(CGPoint)location
{
    return CGRectContainsPoint(self.categoryNameLabel.frame, location) || CGRectContainsPoint(self.categoryTypeLabel.frame, location);
}

- (BOOL)isIdentifierOrDayContainingLocationPoint:(CGPoint)location
{
    return CGRectContainsPoint(self.identifierContainerView.frame, location);
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
    return [self.identifierContainerView viewWithTag:kTagForEntryInstantLabelOfIdentifierContainerView] != nil;
}

- (BOOL)isContainerViewConfiguredWithDay
{
    return ([self.identifierContainerView viewWithTag:kTagForDayIndexLabelOfIdentifierContainerView] != nil);
}

- (BOOL)isContainerViewConfiguredWithNoDay
{
    return ([self.identifierContainerView viewWithTag:kTagForNoDayLabelOfIdentifierContainerVew] != nil);
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
                                                       tag:kTagForEntryInstantLabelOfIdentifierContainerView
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
    UIFont *font = [UIFont fontWithName:kEntryInstantFontFamilyName size:kEntryInstantFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.9 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInteger:0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:kTagForEntryInstantLabelOfIdentifierContainerView];
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)createAndAddInIdentifierContainerViewDayLabels
{
    [self createAndAddInIdentifierContainerViewDayOfTheMonthLabel];
}

- (void)createAndAddInIdentifierContainerViewDayOfTheMonthLabel
{
    UILabel *dayOfTheMonthLabel = [self createEmptyDefaultLabelWithRect:self.identifierContainerView.bounds
                                                                    tag:kTagForDayIndexLabelOfIdentifierContainerView
                                                       andNumberOfLines:2];
    [self.identifierContainerView addSubview:dayOfTheMonthLabel];
}

- (void)configureDayLabelsWithDayOfTheMonthIndex:(NSUInteger)dayOfTheMonthIndex andDayOfTheWeekName:(NSString *)dayOfTheWeekName
{
    [self configureDayOfTheMonthAndWeekLabelWithIndex:dayOfTheMonthIndex andWeekdayName:dayOfTheWeekName];
}

- (void)configureDayOfTheMonthAndWeekLabelWithIndex:(NSUInteger)dayOfTheMonthIndex andWeekdayName:(NSString *)dayOfTheWeekName
{
    UIFont *font = [UIFont fontWithName:kEntryWithNoDayFontFamilyName size:kEntryDayOfTheMonthFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInt:2.0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:kTagForDayIndexLabelOfIdentifierContainerView];
 
    NSString *dayOfTheMonth = [NSString stringWithAtLastTwoDigitFromNumber:[NSNumber numberWithUnsignedInteger:dayOfTheMonthIndex]];
    NSString *dayOfTheWeekNamePrepared = [dayOfTheWeekName substringWithRange:NSMakeRange(0, 3)];
    dayOfTheWeekNamePrepared = [dayOfTheWeekNamePrepared lowercaseString];
    NSString *text = [NSString stringWithFormat:@"%@\n%@", dayOfTheMonth, dayOfTheWeekNamePrepared];
    
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)createAndAddIdentifierWithoutDay
{
    UILabel *label = [self createEmptyDefaultLabelWithRect:self.identifierContainerView.bounds
                                                       tag:kTagForNoDayLabelOfIdentifierContainerVew
                                          andNumberOfLines:2];
    [self.identifierContainerView addSubview:label];
}

- (void)configureNoDayLabel
{
    NSString *text = NSLocalizedString(kLTexForEntryWithNoDay, @"");
    UIFont *font = [UIFont fontWithName:kEntryWithNoDayFontFamilyName size:kEntryWithNoDayFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.8 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInt:0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:kTagForNoDayLabelOfIdentifierContainerVew];
    label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
}


@end
