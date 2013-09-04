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

@class IAEValueDecoratorView;

@interface IAEEditModeConceptCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *conceptInformationContainerView;
@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *valueDecoratorView;
@property (weak, nonatomic) IBOutlet UIView *identifierContainerView;
@property (nonatomic) CGFloat durationOfStrokeStateTransition;
@property (nonatomic, readonly, getter = isInStrokeState) BOOL strokeState;
@property (nonatomic) BOOL drawSeparatorLine;

- (UILabel *)findCategoryLabel;
- (UILabel *)findAmountLabel;

- (void)configureCategoryLabelWithName:(NSString *)name;
- (void)configureAmountLabelWithValue:(NSString *)valueString andColor:(UIColor *)color;

- (void)setIdentifierWithEntryInstantIndex:(NSUInteger)index withAnimationDuration:(CGFloat)animationDuration;
- (void)setIdentifierWithDayOfTheMonthIndex:(NSUInteger)index andDayOfTheWeekName:(NSString *)name;
- (void)setIdentifierWithoutDay;

- (void)setTagWithIndex:(NSUInteger)index;
- (NSUInteger)extractIndexFromTag;

- (BOOL)isAmountLabelContainingLocationPoint:(CGPoint)location;
- (BOOL)isCategoryNameOrTypeContainingLocationPoint:(CGPoint)location;
- (BOOL)isIdentifierOrDayContainingLocationPoint:(CGPoint)location;

- (void)goToStrokeState;
- (void)exitFromStrokeState;

- (void)setVisualAspectInEditMode:(BOOL)editMode forConceptElement:(EditModeConceptElement)conceptElement;

- (NSString *)description;

@end
