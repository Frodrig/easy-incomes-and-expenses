//
//  IAESelectorContextView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESelectorContextView.h"
#import "IAEContextView.h"

@interface IAESelectorContextView()

@property (nonatomic, strong) NSMutableDictionary *contextViews;
@property (nonatomic) NSUInteger actualContextViewIndex;

@end

@implementation IAESelectorContextView

#pragma mark - Constants

static const CGFloat kDurationOfAnimationOfChangeContextOut = 0.65;
static const CGFloat kDurationOfAnimationOfChangeContextIn = 0.5;

#pragma mark - Properties

- (NSMutableDictionary *)contextViews
{
    if (!_contextViews) {
        _contextViews = [[NSMutableDictionary alloc] init];
    }
    
    return _contextViews;
}

#pragma mark - Add

- (BOOL)addContextView:(IAEContextView *)contextView withIndex:(NSUInteger)index
{
    BOOL canAdd = [self canAddContextViewWithIndex:index];
    if (canAdd) {
        self.contextViews[[NSNumber numberWithInt:index]] = contextView;
        [self addSubview:contextView];
        contextView.hidden = YES;
    }
    
    return canAdd;
}

- (BOOL)canAddContextViewWithIndex:(NSUInteger)index
{
    BOOL can = [self findContextViewAtIndex:index] == nil;
    
    return can;
}

#pragma mark - Change Index

- (void)changeToContextViewOfIndex:(NSUInteger)index withAnimation:(BOOL)animation
{
    if ([self findActualContextViewIndex] != index && !self.animationInProgress) {
        void(^logicEndBlock)(void) = ^(void) {
            if ([self.delegate respondsToSelector:@selector(selectorContextView:didChangeToContextViewAtIndex:)]) {
                [self.delegate selectorContextView:self didChangeToContextViewAtIndex:index];
            }
        };
        
        IAEContextView *contextViewToHide = [self findContextViewAtIndex:self.actualContextViewIndex];
        IAEContextView *contextViewToShow = [self findContextViewAtIndex:index];
        if (animation) {
            _animationInProgress = YES;
            
            contextViewToHide.hidden = NO;
            contextViewToShow.hidden = NO;
            contextViewToShow.alpha = 0;
            contextViewToShow.center = CGPointMake(contextViewToShow.center.x, contextViewToShow.center.y * 2);
            const CGFloat durationOut = animation ? kDurationOfAnimationOfChangeContextOut : 0;
            const CGFloat durationIn = animation ? kDurationOfAnimationOfChangeContextIn : 0;
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView animateWithDuration:durationOut animations:^{
                contextViewToHide.alpha = 0;
            } completion:^(BOOL finished) {
                contextViewToHide.alpha = 1.0;
                contextViewToHide.hidden = YES;
            }];
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:durationIn animations:^{
                contextViewToShow.alpha = 1.0;
                contextViewToShow.center = self.center;
            } completion:^(BOOL finished) {
                _animationInProgress = NO;
                logicEndBlock();
            }];

            self.actualContextViewIndex = index;
        } else {
            contextViewToHide.hidden = YES;
            contextViewToShow.hidden = NO;
            self.actualContextViewIndex = index;
            logicEndBlock();
        }
    }
}

#pragma mark - Find

- (NSUInteger)findActualContextViewIndex
{
    return self.actualContextViewIndex;
}

- (IAEContextView *)findContextViewAtIndex:(NSUInteger)index
{
    IAEContextView *contextView = [self.contextViews objectForKey:[NSNumber numberWithInt:index]];
    
    return contextView;
}

- (NSArray *)findAllContextViews
{
    NSArray *keys = [self.contextViews allKeys];
    NSArray *contextViewObjects = [self.contextViews objectsForKeys:[keys sortedArrayUsingSelector:@selector(compare:)]
                                                     notFoundMarker:[NSNull null]];
    
    return contextViewObjects;
}

#pragma mark - Perform actions

- (void)enumerateContextViewsUsingBlock:(void(^)(NSUInteger index, IAEContextView *contextView))block
{
    [self.contextViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *keyObject = key;
        block(keyObject.unsignedIntegerValue, obj);
    }];
}

@end
