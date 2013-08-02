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
        //[self.theBelowView insertSubview:self atIndex:self.theBelowView.subviews.count];
        [self.theBelowView addSubview:self];
    }
}

- (void)doAnimationStrokeOverTheView
{
    [self.delegate strokeAnmatableView:self willStartToStrokeOverTheView:self.theBelowView];
    
    self.backgroundColor = self.strokeColor;
    self.frame = [self calculeFrameToStartToStrokeTheView:self.theBelowView];
    CGPoint endCenterPositionStroke = [self calculeCenterPositionAtTheEndOfTheStrokeTheView:self.theBelowView];
    [UIView animateWithDuration:self.durationOfStrokeAnimation delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.center = endCenterPositionStroke;
    } completion:^(BOOL finished) {
        [self.delegate strokeAnimatableView:self didStrokeOverTheView:self.theBelowView];
    }];
}

- (CGRect)calculeFrameToStartToStrokeTheView:(UIView *)view
{
    CGFloat strokeHeight = [self strokeHeightBasedInConfiguredStrokeType];
    CGRect frameToStartToStroke = CGRectMake(view.frame.origin.x - view.bounds.size.width,
                                             view.center.y - strokeHeight / 2,
                                             view.bounds.size.width,
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

- (CGPoint)calculeCenterPositionAtTheEndOfTheStrokeTheView:(UIView *)view
{
    CGFloat strokeHeight = [self strokeHeightBasedInConfiguredStrokeType];
    CGPoint centerPosition = CGPointMake(view.center.x, self.center.y - strokeHeight / 2);
    
    return centerPosition;
}

- (BOOL)isStrokeActive
{
    return self.theBelowView != nil;
}

@end
