//
//  IAEReportAreaView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEReportAreaView.h"
#import "IAEReportAreaViewDataSource.h"
#import "IAEReportAreaViewDelegate.h"
#import "IAEReportAreaItemView.h"

@implementation IAEReportAreaView

static const CGFloat kWidthForLines = 1.0;
static const CGFloat kColorWithWhiteValueForLines = 0.5;
static const CGFloat kAlphaForColorWithWhiteValueForLines = 1.0;

static const CGFloat kMaxNumberOfReportItemsInScreen = 3.0;

@synthesize delegate = delegate__;

- (void)setDelegate:(id<IAEReportAreaViewDelegate>)delegate
{
    if (delegate != delegate__) {
        [super setDelegate:delegate];
        delegate__ = delegate;
    }
}

- (void)setDataSource:(id<IAEReportAreaViewDataSource>)dataSource
{
    if (dataSource != _dataSource) {
        _dataSource = dataSource;
        if (dataSource == nil) {
            [self releaseData];
        } else {
            [self reloadData];
        }
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initScrollViewProperties];
    }
    return self;
}

- (void)initScrollViewProperties
{
    self.bounces = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.scrollEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    //[self drawHeightLine:contextRef];
    [self drawWidthLine:contextRef];
}

- (void)drawHeightLine:(CGContextRef)contextRef
{
    CGPoint startPosition = CGPointMake(0, 0);
    CGPoint endPosition = CGPointMake(0, startPosition.y + self.frame.size.height);
    [self drawLineWithContextRef:contextRef fromPoint:startPosition toDestinationPoint:endPosition];
}

- (void)drawWidthLine:(CGContextRef)contextRef
{
    CGPoint startPosition = CGPointMake(0, self.frame.size.height);
    CGPoint endPosition = CGPointMake(startPosition.x + self.frame.size.width, startPosition.y);
    [self drawLineWithContextRef:contextRef fromPoint:startPosition toDestinationPoint:endPosition];
}

- (void)drawLineWithContextRef:(CGContextRef)contextRef fromPoint:(CGPoint)fromPoint toDestinationPoint:(CGPoint)destinationPoint
{
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, kWidthForLines);
    
    CGContextMoveToPoint(contextRef, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(contextRef, destinationPoint.x, destinationPoint.y);
    CGContextSetGrayStrokeColor(contextRef, kColorWithWhiteValueForLines, kAlphaForColorWithWhiteValueForLines);
    CGContextStrokePath(contextRef);

    CGContextRestoreGState(contextRef);
}

#pragma mark - Release & Reload

- (void)releaseData
{
    [self removeAllReportAreaItems];
    [self adjustContentSizeAndResetPosition];
}

- (void)reloadData
{
    [self removeAllReportAreaItems];
    [self createAndAddAllReportAreaItems];
    [self adjustContentSizeAndResetPosition];
}

- (void)removeAllReportAreaItems
{
    NSMutableSet *allReportAreaItems = [[NSMutableSet alloc] initWithSet:[self findAllReportAreaItems]];
    while (allReportAreaItems.count > 0) {
        IAEReportAreaItemView *reportAreaItemView = [allReportAreaItems anyObject];
        [reportAreaItemView removeFromSuperview];
        [allReportAreaItems removeObject:reportAreaItemView];
    }
}

- (NSSet *)findAllReportAreaItems
{
    NSMutableSet *allReportAreaItems = [[NSMutableSet alloc] initWithCapacity:self.subviews.count];
    for (IAEReportAreaItemView *viewIt in self.subviews) {
        [allReportAreaItems addObject:viewIt];
    }

    return [NSSet setWithSet:allReportAreaItems];
}

- (void)createAndAddAllReportAreaItems
{
    NSUInteger numberOfReportAreaItems = [self.dataSource numberOfItemsInReportAreaView:self];
    for (NSUInteger reportAreaItemIt = 0; reportAreaItemIt < numberOfReportAreaItems; reportAreaItemIt++) {
        IAEReportAreaItemView *reportAreaItem = [self createReportAreaItemWithIndex:reportAreaItemIt ofTotalNumber:numberOfReportAreaItems];
        [self addSubview:reportAreaItem];
    }
}

- (IAEReportAreaItemView *)createReportAreaItemWithIndex:(NSUInteger)reportAreaItemIndex ofTotalNumber:(NSUInteger)totalNumber
{
    CGRect frameOfReportAreaItem = [self calculeFrameOfReportAreaItemWithIndex:reportAreaItemIndex
                                                                 ofTotalNumber:totalNumber
                                                               maxValueOfItems:[self.dataSource maxValueOfItemsInReportAreaView:self]
                                                 andWidthOfReportAreaItemsView:[self calculeWidthOfReportAreaItemViews]];
    NSString *title = [self.dataSource reportAreaView:self titleOfItemWithIndex:reportAreaItemIndex];
    NSString *subtitle = [self.dataSource reportAreaView:self subtitleOfItemWithIndex:reportAreaItemIndex];
    
    IAEReportAreaItemView *reportAreaItem = [[IAEReportAreaItemView alloc] initWithFrame:frameOfReportAreaItem
                                                                                   title:title
                                                                                subtitle:subtitle
                                                                                andColor:[self.dataSource colorRepresentationOfItemsInReportAreaView:self]];
    
    return reportAreaItem;
}

- (CGFloat)calculeWidthOfReportAreaItemViews
{
    CGFloat width = self.bounds.size.width / kMaxNumberOfReportItemsInScreen;
    
    return width;
}

- (CGRect)calculeFrameOfReportAreaItemWithIndex:(NSUInteger)reportAreaItemIndex
                                  ofTotalNumber:(NSUInteger)totalNumber
                                maxValueOfItems:(CGFloat)maxValueOfItems
                  andWidthOfReportAreaItemsView:(CGFloat)widthOfReportAreaItemsView
{
    CGFloat valueOfReportAreaItem = [self.dataSource reportAreaView:self valueOfItemWithIndex:reportAreaItemIndex];
    CGSize sizeOfItem = CGSizeMake(widthOfReportAreaItemsView,
                                   [self calculeHeightOfReportAreaItemWithMaxValue:maxValueOfItems andReportAreaItemValue:valueOfReportAreaItem]);
    CGFloat xPosition = [self calculeXPositionOfReportAreaItemIndex:reportAreaItemIndex
                                                      ofTotalNumber:totalNumber
                                     withWidthOfReportAreaItemsView:widthOfReportAreaItemsView];
    CGPoint positionOfItem = CGPointMake(xPosition,
                                         self.bounds.size.height - sizeOfItem.height);
    CGRect frameOfReportAreaItem = CGRectMake(positionOfItem.x, positionOfItem.y, sizeOfItem.width, sizeOfItem.height);
    
    return frameOfReportAreaItem;
}

- (CGFloat)calculeXPositionOfReportAreaItemIndex:(NSUInteger)reportAreaItemIndex
                                   ofTotalNumber:(NSUInteger)totalNumber
                  withWidthOfReportAreaItemsView:(CGFloat)widthOfReportAreaItemsView
{
    CGFloat xPosition = 0;
    
    if (totalNumber >= kMaxNumberOfReportItemsInScreen) {
        xPosition = reportAreaItemIndex * widthOfReportAreaItemsView;
    } else {
        const CGFloat xAbsoluteCenter = self.bounds.size.width / 2;
        const CGFloat halfWidthOfReportAreaItem = widthOfReportAreaItemsView / 2;
        if (totalNumber == 1) {
            xPosition = xAbsoluteCenter - halfWidthOfReportAreaItem;
        } else if (totalNumber == 2) {
            const CGFloat halfCenterOfView = xAbsoluteCenter / 2;
            xPosition = reportAreaItemIndex == 0 ? xAbsoluteCenter - halfCenterOfView - halfWidthOfReportAreaItem :
            xAbsoluteCenter + halfCenterOfView - halfWidthOfReportAreaItem;
        }
    }

    return xPosition;
}

- (CGFloat)calculeHeightOfReportAreaItemWithMaxValue:(CGFloat)maxValue andReportAreaItemValue:(CGFloat)valueOfAreaItem
 {
     CGFloat height = (self.bounds.size.height * valueOfAreaItem) / maxValue;
     
     return height;
 }

- (void)adjustContentSizeAndResetPosition
{
    CGFloat width = self.bounds.size.width;
    if (self.subviews.count >= kMaxNumberOfReportItemsInScreen) {
        width *= (self.subviews.count / kMaxNumberOfReportItemsInScreen);
    }
    self.contentSize = CGSizeMake(width, self.bounds.size.height);
    self.contentOffset = CGPointMake(0.0, 0.0);
}

@end
