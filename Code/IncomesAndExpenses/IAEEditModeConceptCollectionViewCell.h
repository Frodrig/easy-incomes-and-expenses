//
//  IAEEditModeConceptCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, EditModeConceptElement) {
    EditModeConceptElement_Category,
    EditModeConceptElement_DayOrNumberInstance,
    EditModeConceptElement_Amount
};

typedef NS_ENUM(NSUInteger, GlobalModeType) {
    GlobalModeTypeData,
    GlobalModeTypeNote,
    GlobalModeTypeUpdating,
    GlobalModeTypeNone,
};

@class IAEValueDecoratorView;

@interface IAEEditModeConceptCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *conceptInformationContainerView;
@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *valueDecoratorView;
@property (weak, nonatomic) IBOutlet UIView *identifierContainerView;
@property (weak, nonatomic) IBOutlet UIView *starContainerView;
@property (nonatomic, readonly) GlobalModeType globalModeType;
@property (nonatomic) CGFloat durationOfStrokeStateTransition;
@property (nonatomic, readonly, getter = isInStrokeState) BOOL strokeState;
@property (nonatomic, readonly) BOOL menuModeActive;
@property (nonatomic) BOOL drawSeparatorLine;
@property (nonatomic) BOOL favoritePinEnabled;

- (UILabel *)findCategoryLabel;
- (UILabel *)findAmountLabel;

- (void)configureCategoryLabelWithName:(NSString *)name;
- (void)configureAmountLabelWithValue:(NSString *)valueString andColor:(UIColor *)color;

- (void)setIdentifierWithEntryInstantIndex:(NSUInteger)index withAnimationDuration:(CGFloat)animationDuration;
- (void)setIdentifierWithDayOfTheMonthIndex:(NSUInteger)index andDayOfTheWeekName:(NSString *)name;
- (void)setIdentifierWithoutDay;

- (void)setTagWithIndex:(NSUInteger)index;
- (NSUInteger)extractIndexFromTag;

- (void)hideFavoritePinWithAnimation:(BOOL)animation;
- (void)showFavoritePin;
- (void)changeStateOfFavoritePin;
- (void)enableFavoritePin;
- (void)disableFavoritePin;

- (BOOL)isFavoritePinContainingLocationPoint:(CGPoint)location;
- (BOOL)isAmountLabelContainingLocationPoint:(CGPoint)location;
- (BOOL)isCategoryNameOrTypeContainingLocationPoint:(CGPoint)location;
- (BOOL)isIdentifierOrDayContainingLocationPoint:(CGPoint)location;
- (BOOL)isDuplicateOptionContainingLocationPoint:(CGPoint)location;
- (BOOL)isCopyOptionContainingLocationPoint:(CGPoint)location;
- (BOOL)isMoveOptionContainingLocationPoint:(CGPoint)location;

- (void)goToStrokeState;
- (void)exitFromStrokeState;

- (void)scrollToMenuMode;
- (void)scrollToNormalModeUsingAnimation:(BOOL)animation;
- (UIView *)viewOfDuplicateMenuOption;
- (UIView *)viewOfCopyMenuOption;
- (UIView *)viewOfMoveMenuOption;

- (GlobalModeType)findGlobalModeTypeIfUpdatingEndsRightNow;
- (void)changeToNoteModeWithAnimation:(BOOL)animation;
- (void)changeToDataModeWithAnimation:(BOOL)animation;
- (void)updateChangeToNoteMode:(CGFloat)percentage;
- (void)updateChangeToDataMode:(CGFloat)percentage;

- (void)setVisualAspectInEditMode:(BOOL)editMode forConceptElement:(EditModeConceptElement)conceptElement;

- (void)doCallForAttentionAnimation;

- (NSString *)description;

@end
