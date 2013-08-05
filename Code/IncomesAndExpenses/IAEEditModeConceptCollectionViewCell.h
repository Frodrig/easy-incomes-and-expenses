//
//  IAEEditModeConceptCollectionViewCell.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class IAEValueDecoratorView;

@interface IAEEditModeConceptCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIView *conceptInformationContainerView;
@property (weak, nonatomic) IBOutlet IAEValueDecoratorView *valueDecoratorView;
@property (weak, nonatomic) IBOutlet UILabel *amountLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UIView *identifierContainerView;
@property (nonatomic) CGFloat durationOfStrokeStateTransition;
@property (nonatomic, readonly, getter = isInStrokeState) BOOL strokeState;

- (void)setIdentifierWithEntryInstantIndex:(NSUInteger)index withAnimationDuration:(CGFloat)animationDuration;
- (void)setIdentifierWithDayOfTheMonthIndex:(NSUInteger)index andDayOfTheWeekName:(NSString *)name;
- (void)setIdentifierWithoutDay;

- (BOOL)isAmountLabelContainingLocationPoint:(CGPoint)location;
- (BOOL)isCategoryNameOrTypeContainingLocationPoint:(CGPoint)location;
- (BOOL)isIdentifierOrDayContainingLocationPoint:(CGPoint)location;

- (void)goToStrokeState;
- (void)exitFromStrokeState;

- (NSString *)description;

@end
