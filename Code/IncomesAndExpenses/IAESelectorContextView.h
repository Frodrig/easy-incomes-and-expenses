//
//  IAESelectorContextView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAESelectorContextViewDelegate.h"

@class IAEContextView;

@interface IAESelectorContextView : UIView

@property (nonatomic, weak) id<IAESelectorContextViewDelegate> delegate;

- (BOOL)addContextView:(IAEContextView *)contextView withIndex:(NSUInteger)index;

- (void)changeToContextViewOfIndex:(NSUInteger)index withAnimation:(BOOL)animation;

- (NSUInteger)findActualContextViewIndex;
- (IAEContextView *)findContextViewAtIndex:(NSUInteger)index;
- (NSArray *)findAllContextViews;

- (void)enumerateContextViewsUsingBlock:(void(^)(NSUInteger index, IAEContextView *contextView))block;

@end
