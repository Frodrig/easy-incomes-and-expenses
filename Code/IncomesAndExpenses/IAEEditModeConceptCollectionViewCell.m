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

static NSString  * const entryInstantFontFamilyName = @"HelveticaNeue-Bold";
static CGFloat entryInstantFontFamilySize = 66;

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
    [self removeIdentifierContainerViewSubviewsIfNotConfiguredWithEntryInstantIndex];
    [self createAndAddInIdentifierContainerViewEntryInstantLabel];
    [self configureEntryInstantLabelWithIndex:index];
}

- (void)setIdentifierWithDayOfTheMonthIndex:(NSUInteger)index andDayOfTheWeekName:(NSString *)name
{
    [self removeIdentifierContainerViewSubviewsIfNotConfiguredWithDay];
    [self createAndAddInIdentifierContainerViewDayLabels];
    [self configureDayLabelsWithDayOfTheMonthIndex:index andDayOfTheWeekName:name];
}

- (void)removeIdentifierContainerViewSubviewsIfNotConfiguredWithEntryInstantIndex
{
    if (![self isContainerViewConfiguredWithEntryInstantIndex]) {
        [self removeIdentifierContainerViewSubviews];
    }
}

- (void)removeIdentifierContainerViewSubviewsIfNotConfiguredWithDay
{
    if (![self isContainerViewConfiguredWithDay]) {
        [self removeIdentifierContainerViewSubviews];
    }
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

- (void)removeIdentifierContainerViewSubviews
{
    while(self.identifierContainerView.subviews.count > 0) {
        UIView *subview = [self.identifierContainerView.subviews objectAtIndex:0];
        [subview removeFromSuperview];
    }
}

- (void)createAndAddInIdentifierContainerViewEntryInstantLabel
{
    UILabel *label = [[UILabel alloc] initWithFrame:self.identifierContainerView.bounds];
    label.tag = tagForEntryInstantLabelOfIdentifierContainerView;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    [label setMinimumScaleFactor:0.1];
    
    [self.identifierContainerView addSubview:label];
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


@end
