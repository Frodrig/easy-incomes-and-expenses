//
//  IAEStrokeAnimatableLine.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEStrokeAnimatableLineView.h"

typedef NS_ENUM(NSInteger, StrokeType) {
    STROKEANIMATABLE_TYPE_THIN,
    STROKEANIMATABLE_TYPE_MEDIUM,
    STROKEANIMATABLE_TYPE_STRONG
};

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
