//
//  UIView+FloatingAnimation.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+FloatingAnimation.h"

static const CGFloat kYTranslationValue = 5.0;
static const CGFloat kFloatingAnimationDuration = 0.75;
static const CGFloat kEndSoftlyAnimationDuration = 0.5;
static NSString * const kAnimationFloatingKey = @"floatingAnimation";
static NSString * const kAnimationEndKey = @"endAnimation";

@implementation UIView (FloatingAnimation)

- (void)startFloatingAnimation
{
    if (![self floatingAnimationActive]) {
        [self.layer addAnimation:[self createFloatingBasicAnimation] forKey:kAnimationFloatingKey];
    } else {
        NSLog(@"CANT START");
    }
}

- (CAAnimation *)createFloatingBasicAnimation
{
    UIBezierPath *bezierPath = [[UIBezierPath alloc] init];
    [bezierPath moveToPoint:CGPointMake(self.layer.position.x, self.layer.position.y)];
    [bezierPath addLineToPoint:CGPointMake(self.layer.position.x, self.layer.position.y - kYTranslationValue)];
    CAKeyframeAnimation *keyframeAnimation = [[CAKeyframeAnimation alloc] init];
    keyframeAnimation.keyPath = @"position";
    keyframeAnimation.path = bezierPath.CGPath;
    keyframeAnimation.duration = kFloatingAnimationDuration;
    keyframeAnimation.repeatCount = INFINITY;
    keyframeAnimation.autoreverses = YES;
    keyframeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    return keyframeAnimation;
}

- (BOOL)floatingAnimationActive
{
    return [self.layer animationForKey:kAnimationFloatingKey] != nil || [self.layer animationForKey:kAnimationEndKey] != nil;
}

- (void)endCurrentFloatingAnimation
{
    if ([self.layer animationForKey:kAnimationFloatingKey]) {
        [self.layer removeAnimationForKey:kAnimationFloatingKey];

        CALayer *presentationLayer = (CALayer *)self.layer.presentationLayer;
        CGPoint originalPosition = self.layer.position;
        self.layer.position = presentationLayer.position;
        
        [self.layer addAnimation:[self createEndSoftlyAnimationFromOriginalPosition:originalPosition] forKey:kAnimationEndKey];
    }
}

- (CAAnimation *)createEndSoftlyAnimationFromOriginalPosition:(CGPoint)originalPosition
{
    CABasicAnimation *endAnimationSoftly = [CABasicAnimation animationWithKeyPath:@"position"];
    endAnimationSoftly.duration = kEndSoftlyAnimationDuration;
    endAnimationSoftly.toValue = [NSValue valueWithCGPoint:originalPosition];
    endAnimationSoftly.removedOnCompletion = NO;
    endAnimationSoftly.fillMode = kCAFillModeForwards;
    endAnimationSoftly.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    endAnimationSoftly.delegate = self;

    return endAnimationSoftly;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([self.layer animationForKey:kAnimationEndKey] == anim) {
        if (flag) {
            CALayer *presentationLayer = (CALayer *)self.layer.presentationLayer;
            self.layer.position = presentationLayer.position;
            [self.layer removeAnimationForKey:kAnimationEndKey];
        }
    }
}

@end
