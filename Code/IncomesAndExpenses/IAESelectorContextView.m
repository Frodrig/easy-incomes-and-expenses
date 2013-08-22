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
@property (nonatomic) BOOL animationInProgress;
@property (nonatomic, strong) NSMutableArray *pendingChangesToContext;

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

- (NSMutableArray *)pendingChangesToContext
{
    if (!_pendingChangesToContext) {
        _pendingChangesToContext = [NSMutableArray array];
    }
    
    return _pendingChangesToContext;
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
    if (self.animationInProgress) {
        [self addToPendingChangesToContextWithViewIndex:index andAnimation:animation];
    } else if ([self findActualContextViewIndex] != index) {
        void(^logicEndBlock)(void) = ^(void) {
            if ([self.delegate respondsToSelector:@selector(selectorContextView:didChangeToContextViewAtIndex:)]) {
                [self.delegate selectorContextView:self didChangeToContextViewAtIndex:index];
            }
            self.animationInProgress = [self processNextPendingChangeToContextIfAppropiate];
        };
        
        IAEContextView *contextViewToHide = [self findContextViewAtIndex:self.actualContextViewIndex];
        IAEContextView *contextViewToShow = [self findContextViewAtIndex:index];
        if (animation) {
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

- (void)addToPendingChangesToContextWithViewIndex:(NSUInteger)index andAnimation:(BOOL)animation
{
    [self.pendingChangesToContext addObject:@{@"index" : [NSNumber numberWithUnsignedInteger:index],
                                              @"animation" : [NSNumber numberWithBool:animation]}];
}

- (BOOL)processNextPendingChangeToContextIfAppropiate
{
    BOOL processNextPendingChangeToContext = self.pendingChangesToContext.count > 0;
    if (processNextPendingChangeToContext){
        NSDictionary *pending = [self.pendingChangesToContext objectAtIndex:0];
        [self.pendingChangesToContext removeObject:pending];
        NSNumber *index = pending[@"index"];
        NSNumber *animation = pending[@"animation"];
        [self changeToContextViewOfIndex:[index unsignedIntegerValue] withAnimation:[animation boolValue]];
    }
    
    return processNextPendingChangeToContext;
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
