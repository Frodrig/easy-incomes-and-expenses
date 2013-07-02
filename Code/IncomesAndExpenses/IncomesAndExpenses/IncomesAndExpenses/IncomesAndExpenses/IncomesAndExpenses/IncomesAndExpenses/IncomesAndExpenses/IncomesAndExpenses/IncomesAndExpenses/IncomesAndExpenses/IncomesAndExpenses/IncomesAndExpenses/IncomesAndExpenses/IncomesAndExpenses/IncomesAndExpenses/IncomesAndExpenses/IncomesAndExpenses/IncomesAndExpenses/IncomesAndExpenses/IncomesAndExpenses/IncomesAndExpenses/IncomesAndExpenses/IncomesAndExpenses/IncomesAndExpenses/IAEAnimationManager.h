//
//  IAEAnimationManager.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 11/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEAnimationManager : NSObject

+ (IAEAnimationManager *)sharedManager;

- (void)scaleFrom:(CATransform3D)from to:(CATransform3D)to forAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration;
- (void)scaleFrom:(CATransform3D)from to:(CATransform3D)to forAnimation:(UIView *)viewForAnimation;

- (void)keyPressEffectForAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration;
- (void)buttonPressedEffect:(UIView *)button;
- (void)buttonReleasedEffect:(UIView *)button;

- (void)FadeToShow:(BOOL)In View:(UIView *)viewToFade;

- (void)destroyViewGosthEffect:(UIView *)srcView withDuration:(CGFloat)duration andDisplacement:(CGFloat)displacement;

- (void)bounceAnimation:(UIView *)viewForAnimation withDuration:(CGFloat)duration;

- (void)animateLabelCounterWithLabel:(UILabel *)label fromValue:(NSDecimalNumber *)from toValue:(NSDecimalNumber *)to withDuration:(CGFloat)duration;
- (void)animateLabelCounterWithLabel:(UILabel *)label WithPrefix:(NSString *)prefix fromValue:(NSDecimalNumber *)from toValue:(NSDecimalNumber *)to withDuration:(CGFloat)duration;

@end
