//
//  IAEStrokeAnimatableLine.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEStrokeAnimatableLineView.h"
#import "IAEStrokeAnimatableViewDelegate.h"

@interface IAEStrokeAnimatableLineView()

@property (nonatomic, weak) UIView *theBelowView;

@end

@implementation IAEStrokeAnimatableLineView

#pragma mark - Constants

static const CGFloat kDefaultDurationOfStrokeAnimation = 0.25;
static const CGFloat kDefaultColorWithWhiteValue = 0.8;
static const CGFloat kDefaultColorWithWhiteAlphaValue = 1.0;
static const StrokeType kDefaultStrokeType = STROKEANIMATABLE_TYPE_MEDIUM;
static const CGFloat kStrokeHeightForStrokeTypeThin = 1.0;
static const CGFloat kStrokeHeightForStrokeTypeMedium = 2.0;
static const CGFloat kStrokeHeightForStrokeTypeStrong = 4.0;

#pragma mark - Factory

+ (instancetype)strokeAnimatableLineView
{
    return [[IAEStrokeAnimatableLineView alloc] init];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"use init");
    return nil;
}

- (id)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self initDefaultValues];
    }
    
    return self;
}

- (CGRect)generateInitialFrameFromPosition:(CGPoint)position
{
    CGRect frame = CGRectMake(position.x, position.y, 0, 0);
    
    return frame;
}

- (void)initDefaultValues
{
    _edgeInsetForHoriziontalCenterAndBottom = CGPointZero;
    _durationOfStrokeAnimation = kDefaultDurationOfStrokeAnimation;
    _strokeColor = [UIColor colorWithWhite:kDefaultColorWithWhiteValue alpha:kDefaultColorWithWhiteAlphaValue];
    _strokeType = kDefaultStrokeType;
    _isAnimationActive = NO;
}

- (void)doStrokeOverTheView:(UIView *)view
{
    [self resetStroke];
    [self vinculeTheStrokedView:view];
    [self doAnimationStrokeOverTheView];
}

- (void)resetStroke
{
    self.theBelowView = nil;
    [self removeFromSuperview];
    [self resetToInitialFrame];
}

- (void)resetToInitialFrame
{
    self.frame = CGRectZero;
}

- (void)vinculeTheStrokedView:(UIView *)view
{
    if (self.theBelowView != view) {
        self.theBelowView = view;
        [self.theBelowView addSubview:self];
    }
}

- (void)doAnimationStrokeOverTheView
{
    if ([self.delegate respondsToSelector:@selector(strokeAnimatableView:willStartToStrokeOverTheView:)]) {
        [self.delegate strokeAnimatableView:self willStartToStrokeOverTheView:self.theBelowView];
    }
    
    self.backgroundColor = self.strokeColor;
    self.frame = [self calculeFrameToStartToStroke];
    CGPoint endCenterPositionStroke = [self calculeCenterPositionAtTheEnd];
    [UIView animateWithDuration:self.durationOfStrokeAnimation delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = endCenterPositionStroke;
    } completion:^(BOOL finished) {
        NSAssert(self.bounds.size.width == self.theBelowView.bounds.size.width, @"");
        if ([self.delegate respondsToSelector:@selector(strokeAnimatableView:didStrokeOverTheView:)]) {
            [self.delegate strokeAnimatableView:self didStrokeOverTheView:self.theBelowView];
        }
    }];
}

- (CGRect)calculeFrameToStartToStroke
{
    CGFloat strokeHeight = [self strokeHeightBasedInConfiguredStrokeType];
    CGFloat strokeWidth = [self strokeWidthBased];
    CGFloat centerAtVerticalPosition = [self calculeCenterAtVerticalPosition];
    CGRect frameToStartToStroke = CGRectMake(-strokeWidth,
                                             centerAtVerticalPosition,
                                             strokeWidth,
                                             strokeHeight);
    
    return frameToStartToStroke;
}

- (CGFloat)strokeHeightBasedInConfiguredStrokeType
{
    CGFloat strokeHeight = [self strokeHeightBasedInStrokeType:self.strokeType];
    
    return strokeHeight;
}

- (CGFloat)strokeHeightBasedInStrokeType:(StrokeType)strokeType
{
    CGFloat strokeHeight = kStrokeHeightForStrokeTypeThin;
    if (strokeType == STROKEANIMATABLE_TYPE_MEDIUM) {
        strokeHeight = kStrokeHeightForStrokeTypeMedium;
    } else if (strokeType == STROKEANIMATABLE_TYPE_STRONG) {
        strokeHeight = kStrokeHeightForStrokeTypeStrong;
    }
    
    return strokeHeight;
}

- (CGFloat)strokeWidthBased
{
    CGFloat width = self.theBelowView.bounds.size.width - self.edgeInsetForHoriziontalCenterAndBottom.x;
    
    return width;
}

- (CGFloat)calculeCenterAtVerticalPosition
{
    CGFloat strokeHeight = [self strokeHeightBasedInConfiguredStrokeType];
    CGFloat halfStrokeHeight = strokeHeight / 2.0;
    CGFloat halfHeightOfTheBelowView = self.theBelowView.bounds.size.height / 2.0;
    CGFloat center = halfHeightOfTheBelowView - halfStrokeHeight - self.edgeInsetForHoriziontalCenterAndBottom.y;

    // Nota: Por algun motivo, centrar sobre una posicion entera produce un glitch. Si tal es el caso restamos 0.5
    //       Usamos fmod porque el operador % no funciona sobre floats o doubles
    if (fmod(center, 2.0) == 0) {
        center -= 0.5;
    }
    
    return center;
}

- (CGPoint)calculeCenterPositionAtTheEnd
{
    CGFloat centerAtVerticalPosition = [self calculeCenterAtVerticalPosition];
    CGPoint centerPosition = CGPointMake(self.theBelowView.bounds.size.width / 2 + self.edgeInsetForHoriziontalCenterAndBottom.x,
                                         centerAtVerticalPosition);
    
    return centerPosition;
}

- (BOOL)isStrokeActive
{
    return self.theBelowView != nil;
}

@end
