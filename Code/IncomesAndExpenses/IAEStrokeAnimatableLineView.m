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

@property (nonatomic, assign) CGPoint initPosition;

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

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"use initWithPosition:");
    return nil;
}

- (id)init
{
    NSAssert(0, @"use initWithPosition:");
    return nil;
}

- (id)initWithPosition:(CGPoint)position
{
    self = [super initWithFrame:[self generateInitialFrameFromPosition:position]];
    if (self) {
        _initPosition = position;
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
    _lenght = 0;
    _isAnimationActive = NO;
}

- (void)doStroke
{
    if ([self canDoStrokeByConfiguration]) {
        [self resetStroke];
        [self makeVisible];
        [self doAnimationStroke];
    }
}

- (BOOL)canDoStrokeByConfiguration
{
    BOOL canDo = _lenght != 0;
    
    return canDo;
}

- (void)resetStroke
{
    if (!self.isHidden) {
        [self resetToInitialFrame];
        [self makeInvisible];
    }
}

- (void)resetToInitialFrame
{
    self.frame = [self generateInitialFrameFromPosition:self.initPosition];    
}

- (void)makeVisible
{
    self.hidden = NO;
}

- (void)makeInvisible
{
    self.hidden = YES;
}

- (void)doAnimationStroke
{
    [self.delegate strokeWillStartInStrokeAnimatableView:self];
    
    self.backgroundColor = self.strokeColor;
    CGRect endFrame = [self calculeEndStrokeFrameForView];
    [UIView animateWithDuration:self.durationOfStrokeAnimation delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.frame = endFrame;
    } completion:^(BOOL finished) {
        [self.delegate strokeDidEndInStrokeAnimatableView:self];
    }];
}

- (CGRect)calculeEndStrokeFrameForView
{
    CGFloat strokeHeight = [self strokeHeightBasedInConfiguredStrokeType];
    CGRect endStrokeFrame = CGRectMake(self.frame.origin.x,
                                       self.frame.origin.y - strokeHeight,
                                       self.frame.size.width + self.lenght,
                                       strokeHeight);
    
    return endStrokeFrame;
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

@end
