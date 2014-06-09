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
#import "UIView+FloatingAnimation.h"

#pragma mark - Constants

static const NSUInteger kTagForEntryInstantLabelOfIdentifierContainerView = 10;
static const NSUInteger kTagForDayIndexLabelOfIdentifierContainerView = 20;
static const NSUInteger kTagForNoDayLabelOfIdentifierContainerVew = 30;

static NSString * const kCategoryLabelFontFamilyName = @"HelveticaNeue-UltraLight";
static const CGFloat kCategoryLabelFontSize = 28;
static NSString * const kConceptAmountLabelFontFamilyName = @"HelveticaNeue-UltraLight";
static const CGFloat kConceptAmountLabelFontFamilySize = 58;

static NSString  * const kEntryInstantFontFamilyName = @"HelveticaNeue-Bold";
static const CGFloat kEntryInstantFontFamilySize = 66;
static NSString * const kEntryWithNoDayFontFamilyName = @"HelveticaNeue";
static const CGFloat kEntryWithNoDayFontFamilySize = 17;
static NSString * const kEntryDayOfTheMonthFontFamilyName = @"HelveticaNeue";
static const CGFloat kEntryDayOfTheMonthFontFamilySize = 24;

static NSString * const kLTexForEntryWithNoDay = @"LTEXT_EDITMODECONCEPTCELL_ENTRYWITHNODAY";

static const CGFloat kDefaultDurationOfStrokeStateModeTransition = 0.25;
static const CGFloat kAlphaValueForStrokeState = 0.3;

static NSString * const kEditModeAnimationKey = @"editModeAnimation";

static const CGFloat kBaseCellIndexValue = 100;

static const CGFloat kDurationOfCallForAttentionAnimationIn = 0.15;
static const CGFloat kDurationOfCallForAttentionAnimationOut = 0.75;
static const CGFloat kCallForAttentionRatioWhiteColor = 0.8;
static const CGFloat kCallForAttentionRationAlphaColor = 0.3;

static const CGFloat kHideShowFavoritePinTime = 0.75;
static const CGFloat kDisableAlphaValueForFavoritePin = 0.3;
static const CGFloat kEnableAlphaValueForFavoritePin = 1.0;

static const CGFloat kMinAlphaInNoteForStarSymbol = 0;
static const CGFloat kMinAlphaInNoteForCategoryLabel = 0.0;
static const CGFloat kMinAlphaInNoteForDayNumberEntryLabel = 0.0;
static const CGFloat kMinAlphaInNoteForDecorator = 1.0;
static const CGFloat kMinAlphaInNoteForAmountLabel = 0.4;

static const NSUInteger kNoteTextFieldWidthMargin = 40;

@interface IAEEditModeConceptCollectionViewCell()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *categoryAndDecoratorContentInformationView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *containerScrollView;
@property (weak, nonatomic) IBOutlet UILabel *optionDuplicateLabel;
@property (weak, nonatomic) IBOutlet UILabel *optionCopyLabel;
@property (weak, nonatomic) IBOutlet UIView *otherOptionsContainerView;
@property (weak, nonatomic) IBOutlet UILabel *optionMoveLabel;
@property (weak, nonatomic) IBOutlet UITextField *noteTextField;
@property (weak, nonatomic) IBOutlet UIView *dayAndOrderLabel;
@property (nonatomic, readwrite) GlobalModeType globalModeType;
@property (nonatomic, readwrite, getter = isInStrokeState) BOOL strokeState;
@property (nonatomic, readwrite) BOOL menuModeActive;

@end

@implementation IAEEditModeConceptCollectionViewCell

#pragma mark - Properties

- (void)setDrawSeparatorLine:(BOOL)drawSeparatorLine
{
    if (drawSeparatorLine != _drawSeparatorLine) {
        _drawSeparatorLine = drawSeparatorLine;
        [self setNeedsDisplay];
    }
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _favoritePinEnabled = YES;
        _menuModeActive = NO;
        _globalModeType = GlobalModeTypeData;
        self.durationOfStrokeStateTransition = kDefaultDurationOfStrokeStateModeTransition;
    }
    
    return self;
}

- (void)awakeFromNib
{
    _globalModeType = GlobalModeTypeData;
    self.noteTextField.delegate = self;
    [self localizedSubmenuOptionLabels];
}

- (void)localizedSubmenuOptionLabels
{
    self.optionCopyLabel.text = NSLocalizedString(@"LTEXT_CONCEPT_SUBMENU_COPY", @"");
    self.optionMoveLabel.text = NSLocalizedString(@"LTEXT_CONCEPT_SUBMENU_MOVE", @"");
    self.optionDuplicateLabel.text = NSLocalizedString(@"LTEXT_CONCEPT_SUBMENU_DUPLICATE", @"");
}

- (void)prepareForReuse
{
    [self setIndividualsInformationElementsWithAlpha:1.0];
    [self removeIdentifierContainerViewSubviews];
    self.durationOfStrokeStateTransition = kDefaultDurationOfStrokeStateModeTransition;
    self.strokeState = NO;
    self.menuModeActive = NO;
    [self executeScrollToNormalModeWithAnimation:NO];
}

- (void)scrollToMenuMode
{
    if (!self.menuModeActive) {
        self.menuModeActive = YES;
        [self executeScrollToMenuModeWithAnimation:YES];
    }
}

- (void)executeScrollToMenuModeWithAnimation:(BOOL)animation
{
    [self.containerScrollView scrollRectToVisible:CGRectMake(self.containerScrollView.contentSize.width - self.containerScrollView.contentSize.width * 0.5, 0, self.containerScrollView.contentSize.width * 0.5, self.containerScrollView.contentSize.height) animated:animation];
}

- (void)scrollToNormalModeUsingAnimation:(BOOL)animation
{
    if (self.menuModeActive) {
        self.menuModeActive = NO;
        [self executeScrollToNormalModeWithAnimation:animation];
    }
}

- (void)executeScrollToNormalModeWithAnimation:(BOOL)animation
{
    [self.containerScrollView scrollRectToVisible:CGRectMake(0, 0, self.containerScrollView.contentSize.width - self.containerScrollView.contentSize.width * 0.5, self.containerScrollView.contentSize.height) animated:animation];
}

- (UIView *)viewOfDuplicateMenuOption
{
    return self.optionDuplicateLabel;
}

- (UIView *)viewOfCopyMenuOption
{
    return self.optionCopyLabel;
}

- (UIView *)viewOfMoveMenuOption
{
    return self.optionMoveLabel;
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    if (self.drawSeparatorLine) {
        [self drawBottomDotLine];
    }
}

#pragma mark - Configuration labels

- (void)configureCategoryLabelWithName:(NSString *)name
{
    NSDictionary *categoryNameLabelAttributes = [self createAttributeDictionaryForConceptCellWithFontName:kCategoryLabelFontFamilyName
                                                                                                     size:kCategoryLabelFontSize
                                                                                             andColor:[UIColor blackColor]];
    self.categoryLabel.attributedText = [[NSAttributedString alloc] initWithString:name
                                                                            attributes:categoryNameLabelAttributes];
    self.categoryLabel.numberOfLines = 2;
}

- (void)configureAmountLabelWithValue:(NSString *)valueString andColor:(UIColor *)color
{
    NSDictionary *amountLabelAttributes = [self createAttributeDictionaryForConceptCellWithFontName:kConceptAmountLabelFontFamilyName
                                                                                               size:kConceptAmountLabelFontFamilySize
                                                                                           andColor:color];
    self.amountLabel.attributedText = [[NSAttributedString alloc] initWithString:valueString attributes:amountLabelAttributes];
}

- (NSDictionary *)createAttributeDictionaryForConceptCellWithFontName:(NSString *)fontFamily
                                                                 size:(CGFloat)size
                                                             andColor:(UIColor *)color
{
    UIFont *font = [UIFont fontWithName:fontFamily size:size];
    NSDictionary *attributes =  @{NSFontAttributeName: font,
                                  NSForegroundColorAttributeName: color,
                                  NSKernAttributeName: [NSNumber numberWithInteger:0.0]};
    
    return attributes;
}

- (UIFont *)createFontForCategoryConceptNameLabelInConceptCell
{
    UIFont *font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:28];
    return font;
}

- (void)configureNoteLabelWithValue:(NSString *)description
{
    self.noteTextField.text = [description stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

#pragma mark - Location Test

- (BOOL)isFavoritePinContainingLocationPoint:(CGPoint)location
{
    return CGRectContainsPoint(self.starContainerView.frame, location);
}

- (BOOL)isAmountLabelContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.amountLabel containingLocationPoint:location fromView:self.conceptInformationContainerView];
}

- (BOOL)isCategoryNameOrTypeContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.categoryLabel containingLocationPoint:location fromView:self.categoryAndDecoratorContentInformationView];
}

- (BOOL)isIdentifierOrDayContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.identifierContainerView containingLocationPoint:location fromView:self.conceptInformationContainerView];
}

- (BOOL)isDuplicateOptionContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.optionDuplicateLabel containingLocationPoint:location fromView:self.otherOptionsContainerView];
}

- (BOOL)isMoveOptionContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.optionMoveLabel containingLocationPoint:location fromView:self.otherOptionsContainerView];
}

- (BOOL)isCopyOptionContainingLocationPoint:(CGPoint)location
{
    return [self isView:self.optionCopyLabel containingLocationPoint:location fromView:self.otherOptionsContainerView];
}

- (BOOL)isView:(UIView *)sourceView containingLocationPoint:(CGPoint)location fromView:(UIView *)fromView
{
    CGRect test = [self convertRect:sourceView.frame fromView:fromView];
    return CGRectContainsPoint(test, location);
}

// Esto va en otra clase como, por ejemplo, un configurador
#pragma mark - EntryIdentifierConfiguration

- (void)setIdentifierWithEntryInstantIndex:(NSUInteger)index withAnimationDuration:(CGFloat)animationDuration
{
    if ([self removeIdentifierContainerViewSubviewsIfNotConfiguredWithEntryInstantIndex]) {
        [self createAndAddInIdentifierContainerViewEntryInstantLabel];
    }
    
    [self configureEntryInstantLabelWithIndex:index withAnimationDuration:animationDuration];
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
    label.opaque = YES;
    [label setMinimumScaleFactor:0.5];
    
    return label;
}

- (void)configureEntryInstantLabelWithIndex:(NSUInteger)index withAnimationDuration:(CGFloat)animationDuration
{
    NSString *text = [NSString stringWithFormat:@"%lu", (unsigned long)index];
    UIFont *font = [UIFont fontWithName:kEntryInstantFontFamilyName size:kEntryInstantFontFamilySize];
    NSDictionary *attributes = @{NSFontAttributeName: font,
                                 NSForegroundColorAttributeName: [UIColor colorWithWhite:0.9 alpha:1.0],
                                 NSKernAttributeName: [NSNumber numberWithInteger:0]};
    
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:kTagForEntryInstantLabelOfIdentifierContainerView];
    if (animationDuration > 0) {
        [UIView animateWithDuration:animationDuration animations:^{
            label.alpha = 0;
        } completion:^(BOOL finished) {
            label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
            [UIView animateWithDuration:animationDuration animations:^{
                label.alpha = 1;
            }];
        }];
    } else {
        label.attributedText = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    }
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

#pragma mark - StrokeState

- (void)goToStrokeState
{
    if (!self.isInStrokeState) {
        [self animateIndividualInformationWithAlpha:kAlphaValueForStrokeState andCompletionLogic:^(BOOL finished) {
            if (finished) {
                self.strokeState = YES;
            }
        }];
    }
}

- (void)exitFromStrokeState
{
    if (self.isInStrokeState) {
        [self animateIndividualInformationWithAlpha:1.0 andCompletionLogic:^(BOOL finished) {
            if (finished) {
                self.strokeState = NO;
            }
        }];
    }
}

- (void)animateIndividualInformationWithAlpha:(CGFloat)alpha andCompletionLogic:(void (^)(BOOL finished))completionLogic
{
    [UIView animateWithDuration:self.durationOfStrokeStateTransition delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self setIndividualsInformationElementsWithAlpha:alpha];
    } completion:^(BOOL finished) {
        completionLogic(finished);
    }];
}

- (void)setIndividualsInformationElementsWithAlpha:(CGFloat)alpha
{
    self.amountLabel.alpha = alpha;
    self.categoryLabel.alpha = alpha;
    self.identifierContainerView.alpha = alpha;
    self.valueDecoratorView.alpha = alpha;
}

#pragma mark - Description

- (NSString *)description
{
    UILabel *label = (UILabel *)[self.identifierContainerView viewWithTag:kTagForEntryInstantLabelOfIdentifierContainerView];
    return label.text;
}

#pragma mark - Find controls

- (UILabel *)findCategoryLabel
{
    return self.categoryLabel;
}

- (UILabel *)findAmountLabel
{
    return self.amountLabel;
}

#pragma mark - setVisualAspectInEditMode

- (void)setVisualAspectInEditMode:(BOOL)editMode forConceptElement:(EditModeConceptElement)conceptElement
{
    UIView *view = [self findViewForConceptElement:conceptElement];
    if (editMode) {
        [view startFloatingAnimation];
    } else {
        [view endCurrentFloatingAnimation];
    }
}

- (UIView *)findViewForConceptElement:(EditModeConceptElement)conceptElement
{
    UIView *view = nil;
    if (conceptElement == EditModeConceptElement_Category) {
        view = self.categoryLabel.superview;
    } else if (conceptElement == EditModeConceptElement_DayOrNumberInstance) {
        view = self.identifierContainerView;
    } else if (conceptElement == EditModeConceptElement_Amount) {
        view = self.amountLabel;
    }
    
    return view;
}

#pragma mark - Tag

- (void)setTagWithIndex:(NSUInteger)index
{
    self.tag = kBaseCellIndexValue + index;
}

- (NSUInteger)extractIndexFromTag
{
    const NSUInteger index = self.tag - kBaseCellIndexValue;
    
    return index;
}

#pragma mark - Speciall Animations

- (void)doCallForAttentionAnimation
{
    __block UIColor *backgroundColor = [self.contentView.backgroundColor copy];
    __block UIColor *destinationColor = [UIColor colorWithWhite:kCallForAttentionRatioWhiteColor alpha:kCallForAttentionRationAlphaColor];

    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
    [UIView animateWithDuration:kDurationOfCallForAttentionAnimationIn animations:^{
        self.contentView.backgroundColor = destinationColor;
    } completion:^(BOOL finished) {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:kDurationOfCallForAttentionAnimationOut animations:^{
            self.contentView.backgroundColor = backgroundColor;
        }];
    }];
}

#pragma mark - Favorite Pin

- (void)hideFavoritePinWithAnimation:(BOOL)animation
{
    if (!self.starContainerView.hidden) {
        if (animation) {
            
            [self.starContainerView.layer removeAllAnimations];
            [UIView animateWithDuration:kHideShowFavoritePinTime animations:^{
                self.starContainerView.alpha = 0.0;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.starContainerView.alpha = 1.0;
                    self.starContainerView.hidden = YES;
                }
            }];
        } else {
            self.starContainerView.hidden = YES;
        }
    }
}

- (void)showFavoritePin
{
    if (self.starContainerView.hidden) {
        [self.starContainerView.layer removeAllAnimations];
        self.starContainerView.hidden = NO;
        self.starContainerView.alpha = 0.0;
        [UIView animateWithDuration:kHideShowFavoritePinTime animations:^{
            self.starContainerView.alpha = self.favoritePinEnabled ? kEnableAlphaValueForFavoritePin : kDisableAlphaValueForFavoritePin;
        } completion:^(BOOL finished) {
        }];
    }
}

- (void)enableFavoritePin
{
    self.favoritePinEnabled = YES;
    self.starContainerView.alpha = self.alpha > 0 ? kEnableAlphaValueForFavoritePin : self.alpha;
}

- (void)disableFavoritePin
{
    self.favoritePinEnabled = NO;
    self.starContainerView.alpha = self.alpha > 0 ? kDisableAlphaValueForFavoritePin : self.alpha;
}

- (void)changeStateOfFavoritePin
{
    NSAssert(!self.starContainerView.hidden, @"");
    self.favoritePinEnabled = !self.favoritePinEnabled;
    self.starContainerView.alpha = self.favoritePinEnabled ? kEnableAlphaValueForFavoritePin : kDisableAlphaValueForFavoritePin;
}

#pragma mark - GlobalMode

- (void)changeToNoteModeWithAnimation:(BOOL)animation
{
    self.globalModeType = GlobalModeTypeNote;
    self.noteTextField.userInteractionEnabled = YES;
    self.containerScrollView.userInteractionEnabled = NO;
    [UIView animateWithDuration:animation ? 0.25 : 0 animations:^{
        self.noteTextField.alpha = 1.0;
        self.starContainerView.alpha = kMinAlphaInNoteForStarSymbol;
        self.categoryAndDecoratorContentInformationView.alpha = kMinAlphaInNoteForDecorator;
        self.amountLabel.alpha = kMinAlphaInNoteForAmountLabel;
        self.dayAndOrderLabel.alpha = kMinAlphaInNoteForDayNumberEntryLabel;
        self.categoryLabel.alpha = kMinAlphaInNoteForCategoryLabel;
    }];
}

- (void)changeToDataModeWithAnimation:(BOOL)animation
{
    self.globalModeType = GlobalModeTypeData;
    self.noteTextField.userInteractionEnabled = NO;
    self.containerScrollView.userInteractionEnabled = YES;
    [UIView animateWithDuration:animation ? 0.25 : 0 animations:^{
        self.noteTextField.alpha = 0;
        self.starContainerView.alpha = self.favoritePinEnabled ? kEnableAlphaValueForFavoritePin : kDisableAlphaValueForFavoritePin;
        self.categoryAndDecoratorContentInformationView.alpha = 1;
        self.amountLabel.alpha = 1;
        self.categoryLabel.alpha = 1;
        self.dayAndOrderLabel.alpha = 1;
    }];
}

- (void)updateChangeToNoteMode:(CGFloat)percentage
{
    self.globalModeType = GlobalModeTypeUpdating;
  
    self.starContainerView.alpha = MAX(kMinAlphaInNoteForStarSymbol, self.starContainerView.alpha - percentage);
    self.categoryAndDecoratorContentInformationView.alpha = MAX(kMinAlphaInNoteForDecorator, self.categoryAndDecoratorContentInformationView.alpha - percentage);
    self.amountLabel.alpha = MAX(kMinAlphaInNoteForAmountLabel, self.amountLabel.alpha - percentage);
    self.categoryLabel.alpha = MAX(kMinAlphaInNoteForCategoryLabel, self.categoryLabel.alpha - percentage);
    self.dayAndOrderLabel.alpha = MAX(kMinAlphaInNoteForDayNumberEntryLabel, self.dayAndOrderLabel.alpha - percentage);
    
    self.noteTextField.alpha = MIN(1.0, self.noteTextField.alpha + percentage);
}

- (void)updateChangeToDataMode:(CGFloat)percentage
{
    self.globalModeType = GlobalModeTypeUpdating;
    
    self.noteTextField.alpha = MAX(0.0 ,self.noteTextField.alpha - percentage);
    
    self.starContainerView.alpha = MIN(self.favoritePinEnabled ? kEnableAlphaValueForFavoritePin : kDisableAlphaValueForFavoritePin, self.starContainerView.alpha + percentage);
    self.categoryAndDecoratorContentInformationView.alpha = MIN(1.0, self.categoryAndDecoratorContentInformationView.alpha + percentage);
    self.amountLabel.alpha = MIN(1.0, self.amountLabel.alpha + percentage);
    self.categoryLabel.alpha = MIN(1.0, self.categoryLabel.alpha + percentage);
    self.dayAndOrderLabel.alpha = MIN(1.0, self.dayAndOrderLabel.alpha + percentage);
}

- (GlobalModeType)findGlobalModeTypeIfUpdatingEndsRightNow
{
    GlobalModeType globalMode = self.globalModeType;
    if (globalMode == GlobalModeTypeUpdating) {
        globalMode = self.noteTextField.alpha > 0.3 ? GlobalModeTypeNote : GlobalModeTypeData;
    }
    
    return globalMode;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyboardSignForEditingConceptsNotes" object:self];

    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self cleanStartAndEndSpacesFromTextField];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self cleanStartAndEndSpacesFromTextField];
    [self endEditing:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"KeyboardResignFromEditingConceptsNotes" object:self];
    
    return YES;
}

- (void)cleanStartAndEndSpacesFromTextField
{
    if (self.noteTextField.text) {
        self.noteTextField.text = [self.noteTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return [self spaceAvailableForCharactersInRange:range withReplacementString:string];
}

- (BOOL)spaceAvailableForCharactersInRange:(NSRange)range withReplacementString:(NSString *)string
{
    NSString *newText = [self.noteTextField.text stringByReplacingCharactersInRange:range withString:string];
    CGSize sizeOfNewText = [newText sizeWithAttributes:self.noteTextField.defaultTextAttributes];
    const BOOL spaceAvailable = sizeOfNewText.width < CGRectGetWidth(self.noteTextField.frame) - kNoteTextFieldWidthMargin;
    
    return spaceAvailable;
}

@end
