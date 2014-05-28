//
//  IAEMainNavigationTitle.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 16/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMainNavigationTitle.h"
#import "NSUserDefaults+EasyIncAndExp.h"

#pragma mark - Constants

static NSString * const kNotificationMainLabelTitleTouched = @"mainLabelTitleTouched";

#pragma mark - Implementation

@implementation IAEMainNavigationTitle

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"Se espera que se cargue desde un StoryBoard / XIB");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureNotificationObservers];
        [self configureTextAndAnimation];
    }
    
    return self;
}
- (void)configureNotificationObservers
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidEnterBackground:)
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationWillEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

- (void)configureTextAndAnimation
{
    [self configureText];
    [self configureAnimation];
}

- (void)configureText
{
    self.text = NSLocalizedString([[NSUserDefaults standardUserDefaults] isProVersionEnabled] ? @"LTEXT_MAINNAVIGATION_TITLE_PROVERSION" : @"LTEXT_MAINNAVIGATION_TITLE_NOPROVERSION" , @"");

}

- (void)configureAnimation
{
    if ([[NSUserDefaults standardUserDefaults] isProVersionEnabled]) {
        [self removeAllAnimations];
    } else {
        [self addAnimations];
    }
}

- (void)removeAllAnimations
{
    [self.layer removeAllAnimations];
    self.alpha = 1.0;
}

- (void)addAnimations
{
    [self.layer addAnimation:[self createAlphaAnimation] forKey:@"proVersionMarketingAlphaAnimation"];
}

- (CABasicAnimation *)createAlphaAnimation
{
    CABasicAnimation *animationAlpha = [CABasicAnimation animationWithKeyPath:@"opacity"];
    animationAlpha.fromValue = @(1.0);
    animationAlpha.toValue = @(0.5);
    animationAlpha.duration = 1.0;
    animationAlpha.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    animationAlpha.autoreverses = YES;
    animationAlpha.repeatCount = HUGE_VALF;

    return animationAlpha;
}

- (void)reloadTitle
{
    [self configureTextAndAnimation];
}

#pragma mark - Interaction

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:kNotificationMainLabelTitleTouched object:self];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - Notification center

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self removeAllAnimations];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self configureAnimation];
}

@end
