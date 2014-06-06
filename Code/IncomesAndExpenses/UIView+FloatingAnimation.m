//
//  UIView+FloatingAnimation.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/06/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+FloatingAnimation.h"

static const CGFloat kYTranslationValue = 5.0;
static NSString * const kAnimationKey = @"floatingAnimation";

@implementation UIView (FloatingAnimation)

- (void)startFloatingAnimation
{
    if (![self floatingAnimationActive]) {
        [self.layer addAnimation:[self createFloatingBasicAnimation] forKey:kAnimationKey];
    }
}

- (CABasicAnimation *)createFloatingBasicAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    animation.removedOnCompletion = NO;
    animation.autoreverses = YES;
    animation.repeatCount = HUGE_VALF;
    animation.toValue = @(kYTranslationValue);
    animation.duration = 1;
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    animation.cumulative = NO;

    return animation;
}

- (BOOL)floatingAnimationActive
{
    return [self.layer animationForKey:kAnimationKey] != nil;
}

- (void)endCurrentFloatingAnimation
{
    [self.layer removeAnimationForKey:kAnimationKey];
}

@end
