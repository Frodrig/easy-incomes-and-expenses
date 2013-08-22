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

- (BOOL)addContextView:(IAEContextView *)contextView withIndex:(NSUInteger)index
{
    return NO;
}

- (BOOL)canAddContextViewWithIndex:(NSUInteger)index
{
    BOOL can = [self findContextViewAtIndex:index] != nil;
    
    return can;
}

- (void)changeToContextViewOfIndex:(NSUInteger)index withAnimation:(BOOL)animation
{
    if ([self findActualContextViewIndex] != index) {
        IAEContextView *contextViewToHide = [self findContextViewAtIndex:self.actualContextViewIndex];
        IAEContextView *contextViewToShow = [self findContextViewAtIndex:index];
        contextViewToHide.hidden = YES;
        contextViewToShow.hidden = NO;
        self.actualContextViewIndex = index;
    }
}

- (NSUInteger)findActualContextViewIndex
{
    return self.actualContextViewIndex;
}

- (IAEContextView *)findContextViewAtIndex:(NSUInteger)index
{
    IAEContextView *contextView = [self.contextViews objectForKey:@(index)];
    
    return contextView;
}

- (NSArray *)findAllContextViews
{
    NSArray *keys = [self.contextViews allKeys];
    NSArray *contextViewObjects = [self.contextViews objectsForKeys:[keys sortedArrayUsingSelector:@selector(compare:)]
                                                     notFoundMarker:[NSNull null]];
    
    return contextViewObjects;
}

- (void)enumerateContextViewsUsingBlock:(void(^)(NSUInteger index, IAEContextView *contextView))block
{
    [self.contextViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *keyObject = key;
        block(keyObject.unsignedIntegerValue, obj);
    }];
}

@end
