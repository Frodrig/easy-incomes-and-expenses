//
//  IAEAnimationManager.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 11/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEAnimationManager.h"
#import "IAECurrencyManager.h"
#import "IAEConstants.h"
#include <QuartzCore/QuartzCore.h>

@interface IAEAnimationManager()

@property (nonatomic, strong) NSMutableArray *animateLabelCountersPending;
@property (nonatomic, strong) CADisplayLink *displayLink;

@end

@implementation IAEAnimationManager

@synthesize animateLabelCountersPending = animatedLabelCountersPending_;
@synthesize displayLink = displayLink_;

- (NSMutableArray *)animateLabelCountersPending
{
    if (nil == animatedLabelCountersPending_)
        animatedLabelCountersPending_ = [NSMutableArray array];
    
    return animatedLabelCountersPending_;
}

- (CADisplayLink *)displayLink
{
    if (nil == displayLink_)
        displayLink_ = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction:)];

    return displayLink_;
}

+ (IAEAnimationManager *)sharedManager
{
    static IAEAnimationManager *sharedManager = nil;
    
    if (nil == sharedManager)
        sharedManager = [[super allocWithZone:nil] init];
    
    return sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedManager];
}

- (void)scaleFrom:(CATransform3D)from to:(CATransform3D)to forAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    scale.values = [NSArray arrayWithObjects:
                    [NSValue valueWithCATransform3D:from],
                    [NSValue valueWithCATransform3D:to],
                    nil];
    
    scale.duration = duration;
    
    [viewForAnimation.layer addAnimation:scale forKey:@"scaleFromToAnimation"];
}

- (void)keyPressEffectForAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    scale.values = [NSArray arrayWithObjects:
                    [NSValue valueWithCATransform3D:CATransform3DIdentity],
                    [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)],
                    [NSValue valueWithCATransform3D:CATransform3DIdentity],
                    nil];
    
    scale.duration = duration;
    
    [viewForAnimation.layer addAnimation:scale forKey:@"keyPressEffectForAnimation"];
}

- (void)buttonPressedEffect:(UIView *)button
{
    button.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1.0);
}

- (void)buttonReleasedEffect:(UIView *)button
{
    CAKeyframeAnimation *scale = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    scale.values = [NSArray arrayWithObjects: [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.7, 0.7, 1.0)], [NSValue valueWithCATransform3D:CATransform3DIdentity], nil];
    scale.duration = 0.3;
    [button.layer addAnimation:scale forKey:@"keyPressEffectForAnimationRelease"];
    button.layer.transform = CATransform3DIdentity;
}


- (void)scaleFrom:(CATransform3D)from to:(CATransform3D)to forAnimation:(UIView *)viewForAnimation
{
    [self scaleFrom:from to:to forAnimation:viewForAnimation withDuration:0.35];
}

- (void)bounceAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration
{
    CATransform3D forward = CATransform3DMakeScale(1.3, 1.3, 1);
    CATransform3D back = CATransform3DMakeScale(0.7, 0.7, 1);
    CATransform3D forward2 = CATransform3DMakeScale(1.2, 1.2, 1);
    CATransform3D back2 = CATransform3DMakeScale(0.9, 0.9, 1);
    
    CAKeyframeAnimation *bounce = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    
    bounce.values = [NSArray arrayWithObjects:
                     [NSValue valueWithCATransform3D:CATransform3DIdentity],
                     [NSValue valueWithCATransform3D:forward],
                     [NSValue valueWithCATransform3D:back],
                     [NSValue valueWithCATransform3D:forward2],
                     [NSValue valueWithCATransform3D:back2],
                     [NSValue valueWithCATransform3D:CATransform3DIdentity],
                     nil];
    
    bounce.duration = duration;
    
    [viewForAnimation.layer addAnimation:bounce forKey:@"bounceAnimation"];
}

- (void)destroyViewGosthEffect:(UIView *)srcView withDuration:(CGFloat)duration andDisplacement:(CGFloat)displacement
{
    NSData *tempArchive = [NSKeyedArchiver archivedDataWithRootObject:srcView];
    __block UIView *viewToApplyGosthEffect = (UIView *)[NSKeyedUnarchiver unarchiveObjectWithData:tempArchive];
    
    [srcView.superview addSubview:viewToApplyGosthEffect];
    
    [UIView animateWithDuration:duration animations:^{
        viewToApplyGosthEffect.frame = CGRectMake(viewToApplyGosthEffect.frame.origin.x, viewToApplyGosthEffect.frame.origin.y + displacement, viewToApplyGosthEffect.frame.size.width, viewToApplyGosthEffect.frame.size.height);
        viewToApplyGosthEffect.alpha = 0.0;
    } completion:^(BOOL finished) {
        [viewToApplyGosthEffect removeFromSuperview];
        viewToApplyGosthEffect = nil;
    }];
}

- (BOOL)isLabelCounterProcessingAnimation:(UILabel *)label
{
    BOOL isProcessingAnimation = NO;
    
    for (NSDictionary *animationCounters in self.animateLabelCountersPending) {
        UILabel *labelIt = [animationCounters objectForKey:@"label"];
        isProcessingAnimation = labelIt == label;
        if (isProcessingAnimation) {
            break;
        }
    }
    
    return isProcessingAnimation;
}

- (void)animateLabelCounterWithLabel:(UILabel *)label WithPrefix:(NSString *)prefix fromValue:(NSDecimalNumber *)from toValue:(NSDecimalNumber *)to withDuration:(CGFloat)duration
{
    if (![self isLabelCounterProcessingAnimation:label]) {
        NSDictionary *labelCounterData = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:label, prefix, [from copy], [to copy], [NSNumber numberWithFloat:duration], [NSNumber numberWithDouble:CACurrentMediaTime()], nil]
                                                                     forKeys:[NSArray arrayWithObjects:@"label", @"prefix", @"from", @"to", @"duration", @"startTime", nil]];
    
        if (self.animateLabelCountersPending.count == 0) {
            [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
        }
    
        [self.animateLabelCountersPending addObject:labelCounterData];
    }
}

- (void)animateLabelCounterWithLabel:(UILabel *)label fromValue:(NSDecimalNumber *)from toValue:(NSDecimalNumber *)to withDuration:(CGFloat)duration
{
    [self animateLabelCounterWithLabel:label WithPrefix:@"" fromValue:from toValue:to withDuration:duration];
}

- (void)displayLinkAction:(CADisplayLink *)link
{
    if (link == self.displayLink)
    {
        NSMutableArray *labelCounterDataPendingToRemove = [NSMutableArray arrayWithCapacity:self.animateLabelCountersPending.count];
        
        for (NSDictionary *labelCounterData in self.animateLabelCountersPending)
        {
            NSDecimalNumber *from = [labelCounterData objectForKey:@"from"];
            NSString *prefix = [labelCounterData objectForKey:@"prefix"];
            NSDecimalNumber *to = [labelCounterData objectForKey:@"to"];
            NSNumber *duration = [labelCounterData objectForKey:@"duration"];
            NSNumber *startTime = [labelCounterData objectForKey:@"startTime"];
            
            float dt = (link.timestamp - startTime.floatValue) / duration.doubleValue;
            
            NSDecimalNumber *currentCounterValue;
            if (dt >= 1)
            {
                currentCounterValue = to;
                
                [labelCounterDataPendingToRemove addObject:labelCounterData];
            }
            else
            {
                if ([to compare:from] == NSOrderedDescending)
                {
                    currentCounterValue = [to decimalNumberBySubtracting:from];
                    currentCounterValue = [currentCounterValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:dt] stringValue]]];
                    currentCounterValue = [currentCounterValue decimalNumberByAdding:from];
                }
                else
                {
                    currentCounterValue = [from decimalNumberBySubtracting:to];
                    currentCounterValue = [currentCounterValue decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:[[NSNumber numberWithFloat:dt] stringValue]]];
                    currentCounterValue = [from decimalNumberBySubtracting:currentCounterValue];
                }
                
            }
            
            UILabel *label = [labelCounterData objectForKey:@"label"];
            label.text = [NSString stringWithFormat:@"%@%@", prefix, [[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:currentCounterValue]];
        }
        
        [self.animateLabelCountersPending removeObjectsInArray:labelCounterDataPendingToRemove];
        
        if (self.animateLabelCountersPending.count == 0)
            [self.displayLink removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
    }
}

- (void)FadeToShow:(BOOL)In View:(UIView *)viewToFade
{
    // Solo procesamos si tiene sentido hacerlo
    if (viewToFade.hidden == In) {
        if (In) {
            viewToFade.alpha = 0.0;
            viewToFade.hidden = NO;
        }
        
        [UIView animateWithDuration:0.35 animations:^{
            viewToFade.alpha = In ? 1.0 : 0.0;
        } completion:^(BOOL finished) {
            viewToFade.alpha = 1.0;
            viewToFade.hidden = In ? NO : YES;
        }];
    }
}


@end
