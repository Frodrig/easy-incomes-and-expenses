//
//  IAEStrokeAnimatableLine.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEStrokeAnimatableLineViewDefs.h"

@protocol IAEStrokeAnimatableViewDelegate;

@interface IAEStrokeAnimatableLineView : UIView

@property (nonatomic, weak) id<IAEStrokeAnimatableViewDelegate> delegate;

@property (nonatomic) CGPoint edgeInsetForHoriziontalCenterAndBottom;
@property (nonatomic) CGFloat durationOfStrokeAnimation;
@property (nonatomic) StrokeType strokeType;
@property (nonatomic, copy) UIColor *strokeColor;
@property (nonatomic, readonly) BOOL isAnimationActive;

+ (instancetype)strokeAnimatableLineView;

- (void)doStrokeOverTheView:(UIView *)view;
- (void)resetStroke;

- (BOOL)isStrokeActive;

@end
