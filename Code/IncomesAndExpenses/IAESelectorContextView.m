//
//  IAESelectorContextView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 22/08/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAESelectorContextView.h"
#import "IAEContextView.h"
#import "IAEContextSubmenuView.h"
#import "IAEContextSubmenuViewDelegate.h"
#import "IAEContextSubmenuViewDatasource.h"
#import "UIView+LoadFromXib.h"

@interface IAESelectorContextView()<IAEContextSubmenuViewDelegate,
                                    IAEContextSubmenuViewDatasource>

@property (nonatomic, strong) NSMutableDictionary *contextViews;
@property (nonatomic) NSUInteger actualContextViewIndex;
@property (nonatomic, strong) UIScrollView *scrollViewContainer;
@property (nonatomic, strong) IAEContextSubmenuView *contextSubmenuView;

@end

@implementation IAESelectorContextView

#pragma mark - Constants

static const CGFloat kDurationOfAnimationOfChangeContext = 0.6;

#pragma mark - Properties

- (NSMutableDictionary *)contextViews
{
    if (!_contextViews) {
        _contextViews = [[NSMutableDictionary alloc] init];
    }
    
    return _contextViews;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createAndVinculeBaseSubviews];
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self createAndVinculeBaseSubviews];
    }
    
    return self;
}

- (void)createAndVinculeBaseSubviews
{
    [self createAndConfigureContextSubmenuView];
    [self createConfigureAndVinculeScrollViewContainer];
}

- (void)createAndConfigureContextSubmenuView
{
    self.contextSubmenuView = (IAEContextSubmenuView *)[UIView viewFromXib:@"IAEContextSubmenuView" withOwner:self];
    self.contextSubmenuView.delegate = self;
    self.contextSubmenuView.datasource = self;
}

- (void)createConfigureAndVinculeScrollViewContainer
{
    self.scrollViewContainer = [[UIScrollView alloc] initWithFrame:self.bounds];
    self.scrollViewContainer.contentSize = CGSizeMake(self.bounds.size.width + self.contextSubmenuView .bounds.size.width, self.bounds.size.height);
    self.scrollViewContainer.pagingEnabled = YES;
    self.scrollViewContainer.backgroundColor = [UIColor clearColor];
    self.scrollViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
    self.scrollViewContainer.autoresizesSubviews = YES;
    self.scrollViewContainer.showsHorizontalScrollIndicator = NO;
    self.scrollViewContainer.showsVerticalScrollIndicator = NO;
    self.scrollViewContainer.bounces = NO;
    [self.scrollViewContainer scrollRectToVisible:CGRectZero animated:NO];
    
    [self addContextsubMenuViewIntoScrollViewContainer];
    [self addSubview:self.scrollViewContainer];
}

- (void)addContextsubMenuViewIntoScrollViewContainer
{
    [self.scrollViewContainer addSubview:self.contextSubmenuView];
    self.contextSubmenuView.frame = CGRectOffset(self.contextSubmenuView.frame, self.scrollViewContainer.contentSize.width - self.contextSubmenuView.bounds.size.width, 100);
}

#pragma mark - Add

- (BOOL)addContextView:(IAEContextView *)contextView withIndex:(NSUInteger)index
{
    BOOL canAdd = [self canAddContextViewWithIndex:index];
    if (canAdd) {
        self.contextViews[[NSNumber numberWithInt:index]] = contextView;
        contextView.backgroundColor = [UIColor clearColor];
        [self.scrollViewContainer addSubview:contextView];
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
        IAEContextView *contextViewToHide = [self findContextViewAtIndex:self.actualContextViewIndex];
        IAEContextView *contextViewToShow = [self findContextViewAtIndex:index];
        self.actualContextViewIndex = index;
        if (animation) {
            [self doAnimationToHideContextView:contextViewToHide andShowContextView:contextViewToShow];
        } else {
            [self hideWithoutAnimationTheContextView:contextViewToHide andShowTheContextView:contextViewToShow];
        }
    }
}

- (void)doAnimationToHideContextView:(IAEContextView *)contextViewToHide andShowContextView:(IAEContextView *)contextViewToShow
{
    _animationInProgress = YES;
    
    contextViewToHide.hidden = NO;
    contextViewToShow.hidden = NO;
    contextViewToShow.alpha = 0;
    contextViewToShow.center = CGPointMake(contextViewToShow.center.x, contextViewToShow.center.y * 2);
    [contextViewToShow reloadDataWithAnimationFromUsingZeroValue:YES];

    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView animateWithDuration:kDurationOfAnimationOfChangeContext animations:^{
        contextViewToHide.alpha = 0;
        contextViewToShow.alpha = 1.0;
        contextViewToShow.center = CGPointMake(contextViewToShow.center.x, contextViewToShow.center.y / 2);
    } completion:^(BOOL finished) {
        contextViewToHide.alpha = 1.0;
        contextViewToHide.hidden = YES;
        _animationInProgress = NO;
        [self sendToDelegateChangeToContextViewAtIndex:index];
    }];
    
}

- (void)hideWithoutAnimationTheContextView:(IAEContextView *)contextViewToHide andShowTheContextView:(IAEContextView *)contextViewToShow
{
    contextViewToHide.alpha = 1.0;
    contextViewToHide.hidden = YES;
    contextViewToShow.hidden = NO;
    
    [contextViewToShow reloadDataWithoutAnimation];

    _animationInProgress = NO;
    [self sendToDelegateChangeToContextViewAtIndex:index];
}

- (void)sendToDelegateChangeToContextViewAtIndex:(NSUInteger)index
{
    if ([self.delegate respondsToSelector:@selector(selectorContextView:didChangeToContextViewAtIndex:)]) {
        [self.delegate selectorContextView:self didChangeToContextViewAtIndex:index];
    }
}

#pragma mark - Find

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

#pragma mark - Perform actions

- (void)enumerateContextViewsUsingBlock:(void(^)(NSUInteger index, IAEContextView *contextView))block
{
    [self.contextViews enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSNumber *keyObject = key;
        block(keyObject.unsignedIntegerValue, obj);
    }];
}

#pragma mark - Menu Mode

- (void)hideMenuModeWithAnimation:(BOOL)animation
{
    [self.scrollViewContainer scrollRectToVisible:CGRectZero animated:animation];
}

- (BOOL)isInMenuMode
{
    return self.scrollViewContainer.contentOffset.x > 0;
}

#pragma mark - IAEContextSubmenuDelegate

- (void)exportCSVOptionWasPressedInContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView
{
    [self.delegate selectorContextView:self didSelectExportCSVOptionAtIndex:self.actualContextViewIndex];
}

- (void)removeAllConceptsOptionWasPressedInContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView
{
    [self.delegate selectorContextView:self didSelectRemoveAllConceptsOptionAtIndex:self.actualContextViewIndex];
}

#pragma mark - IAEContextSubmenuDatasource

- (BOOL)isActualContextAYearForContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView
{
    return [self isActualContextOfType:CONTEXT_VIEW_YEAR];
}

- (BOOL)isActualContextAMonthForContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView
{
    return [self isActualContextOfType:CONTEXT_VIEW_MONTH];
}

- (BOOL)isActualContextOfType:(IAEContextViewType)contextType
{
    return [self findContextViewAtIndex:[self findActualContextViewIndex]].contextType == contextType;
}

@end
