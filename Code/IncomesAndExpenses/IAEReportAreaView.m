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
        [self reloadData];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

#pragma mark - Draw

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    [self drawHeightLine:contextRef];
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

#pragma mark - Reload

- (void)reloadData
{
    [self removeAllReportAreaItems];
    [self createAndAddReportAreaItems];
    [self adjustContentSize];
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
    for (UIView *viewIt in self.subviews) {
        if ([viewIt isKindOfClass:[IAEReportAreaItemView class]]) {
            [allReportAreaItems addObject:viewIt];
        }
    }
    
    return [NSSet setWithSet:allReportAreaItems];
}

- (void)createAndAddReportAreaItems
{
    CGFloat maxValueOfItemsInReportAreaView = [self.dataSource maxValueOfItemsInReportAreaView:self];
    CGFloat widthOfReportAreaItems = [self calculeWidthOfReportAreaItemViews];
    UIColor *colorRepresentationOfReportAreaItems = [self.dataSource colorRepresentationOfItemsInReportAreaView:self];
    
    NSUInteger numberOfReportAreaItems = [self.dataSource numberOfItemsInReportAreaView:self];
    for (NSUInteger reportAreaItemIt = 0; reportAreaItemIt < numberOfReportAreaItems; reportAreaItemIt++) {
        CGRect frameOfReportAreaItem = [self calculeFrameOfReportAreaItemWithIndex:reportAreaItemIt
                                                                   maxValueOfItems:maxValueOfItemsInReportAreaView
                                                     andWidthOfReportAreaItemsView:widthOfReportAreaItems];
        
        IAEReportAreaItemView *reportAreaItem = [[IAEReportAreaItemView alloc] initWithFrame:frameOfReportAreaItem];
        //reportAreaItem.title = [self.dataSource reportAreaView:self titleOfItemWithIndex:reportAreaItemIt];
        //reportAreaItem.subtitle = [self.dataSource reportAreaView:self subtitleOfItemWithIndex:reportAreaItemIt];
    }
}

- (CGFloat)calculeWidthOfReportAreaItemViews
{
    CGFloat width = self.bounds.size.width / kMaxNumberOfReportItemsInScreen;
    
    return width;
}

- (CGRect)calculeFrameOfReportAreaItemWithIndex:(NSUInteger)reportAreaItemIndex
                                maxValueOfItems:(CGFloat)maxValueOfItems
                  andWidthOfReportAreaItemsView:(CGFloat)widthOfReportAreaItemsView
{
    CGFloat valueOfReportAreaItem = [self.dataSource reportAreaView:self valueOfItemWithIndex:reportAreaItemIndex];
    CGSize sizeOfItem = [self calculeSizeOfReportAreaItemWithMaxValue:maxValueOfItems andReportAreaItemValue:valueOfReportAreaItem];
    CGPoint positionOfItem = CGPointMake(reportAreaItemIndex * widthOfReportAreaItemsView, self.bounds.size.height - sizeOfItem.height);
    CGRect frameOfReportAreaItem = CGRectMake(positionOfItem.x, positionOfItem.y, sizeOfItem.width, sizeOfItem.height);
    
    return frameOfReportAreaItem;
}

- (CGSize)calculeSizeOfReportAreaItemWithMaxValue:(CGFloat)maxValue andReportAreaItemValue:(CGFloat)valueOfAreaItem
 {
     return CGSizeZero;
 }

- (void)adjustContentSize
{
    CGFloat width = self.bounds.size.width * (self.subviews.count / kMaxNumberOfReportItemsInScreen);
    self.contentSize = CGSizeMake(width, self.bounds.size.height);
}

@end
