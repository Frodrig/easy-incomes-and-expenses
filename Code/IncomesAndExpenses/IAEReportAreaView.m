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
#import "IAEEconomicValueUpdater.h"
#import "IAECurrencyManager.h"

@interface IAEReportAreaView()

@property (nonatomic, strong) UILabel *noItemsLabel;

@end

@implementation IAEReportAreaView

#pragma mark - Constants

static NSString * const kLtextReportAreaItemsNoItemsWarning = @"LTEXT_REPORTAREAITEMS_NOITEMSWARNING";
static NSString * const kReportAreaItemsNoItemsWarningFontName = @"HelveticaNeue-Ultralight";
static const CGFloat kReportAreaItemsNoItemsFontSize = 36;
static const CGFloat kReportAreaItemsNoItemsWarningKern = 0;

static const CGFloat kXOffsetToStartDrawingReportAreaItems =0;

static const CGFloat kWidthForLines = 1.0;
static const CGFloat kColorWithWhiteValueForLines = 0.5;
static const CGFloat kAlphaForColorWithWhiteValueForLines = 1.0;

static const CGFloat kMaxNumberOfReportItemsInScreen = 3.0;

static const CGFloat kDurationOfReportItemViewAppear = 0.75;
static const CGFloat kDurationOfReportItemViewDisappear = 0.75;

@synthesize delegate = delegate__;

#pragma mark - Properties

- (UILabel *)noItemsLabel
{
    if (!_noItemsLabel) {
        _noItemsLabel = [[UILabel alloc] initWithFrame:self.bounds];
        UIFont *fontForText = [UIFont fontWithName:kReportAreaItemsNoItemsWarningFontName size:kReportAreaItemsNoItemsFontSize];
        NSDictionary *attributesForText = @{NSFontAttributeName: fontForText,
                                            NSForegroundColorAttributeName: [UIColor blackColor],
                                            NSKernAttributeName: @(kReportAreaItemsNoItemsWarningKern)};
        _noItemsLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLtextReportAreaItemsNoItemsWarning, @"")
                                                                       attributes:attributesForText];
        _noItemsLabel.textAlignment = NSTextAlignmentCenter;
        _noItemsLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _noItemsLabel;
}

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
        if (!dataSource) {
            [self releaseData];
        } else {
            [self reloadDataWithAnimation:NO];
        }
    }
}

#pragma mark - Init

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
    //[self drawDotInCenterWithContextRef:contextRef];
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

- (void)drawDotInCenterWithContextRef:(CGContextRef)contextRef
{
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 1);
    
    CGContextMoveToPoint(contextRef, self.bounds.size.width / 2, self.bounds.size.height - 44);
    CGContextAddLineToPoint(contextRef, self.bounds.size.width / 2, self.bounds.size.height);
    CGContextSetStrokeColorWithColor(contextRef, [UIColor blueColor].CGColor);
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

#pragma mark - Release & Reload

- (void)releaseData
{
    [self removeAllReportAreaItemsWithAnimation:NO andExecuteBlockAtCompletion:nil];
    [self adjustContentSizeAndResetPosition];
}

- (void)reloadDataWithAnimation:(BOOL)animation
{
    [self desvinculeNoItemsLabels];
    [self removeAllReportAreaItemsWithAnimation:animation andExecuteBlockAtCompletion:^(void) {
        [self createAndAddAllReportAreaItemsWithAnimation:animation];
        [self adjustContentSizeAndResetPosition];
    }];
}

- (void)desvinculeNoItemsLabels
{
    [self.noItemsLabel removeFromSuperview];
}

- (void)removeAllReportAreaItemsWithAnimation:(BOOL)animation andExecuteBlockAtCompletion:(void(^)(void))block
{
    NSMutableSet *allReportAreaItems = [[NSMutableSet alloc] initWithSet:[self findAllReportAreaItems]];
    __block NSUInteger numberOfAreaItemsToRemove = allReportAreaItems.count;
    if (numberOfAreaItemsToRemove > 0) {
        for (IAEReportAreaItemView *reportAreaItemView in allReportAreaItems) {
            if (animation) {
                [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:reportAreaItemView.title
                                                                                    toValue:[NSDecimalNumber zero]
                                                                               withDuration:kDurationOfReportItemViewDisappear];
                [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
                [UIView animateWithDuration:kDurationOfReportItemViewAppear animations:^{
                    reportAreaItemView.frame = CGRectMake(reportAreaItemView.frame.origin.x, reportAreaItemView.frame.origin.y + reportAreaItemView.frame.size.height, reportAreaItemView.frame.size.width, 0.0);
                } completion:^(BOOL finished) {
                    [reportAreaItemView removeFromSuperview];
                    --numberOfAreaItemsToRemove;
                    if (0 == numberOfAreaItemsToRemove) {
                        if (block) {
                            block();
                        }
                    }
                }];
            } else {
                [reportAreaItemView removeFromSuperview];
                if (block) {
                    block();
                }
            }
        }
    } else {
        if (block) {
            block();
        }
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

- (void)createAndAddAllReportAreaItemsWithAnimation:(BOOL)animation
{
    NSUInteger numberOfReportAreaItems = [self.dataSource numberOfItemsInReportAreaView:self];
    if (numberOfReportAreaItems > 0) {
        for (NSUInteger reportAreaItemIt = 0; reportAreaItemIt < numberOfReportAreaItems; reportAreaItemIt++) {
            IAEReportAreaItemView *reportAreaItem = [self createReportAreaItemWithIndex:reportAreaItemIt ofTotalNumber:numberOfReportAreaItems];
            [self addSubview:reportAreaItem];
        }
        if (animation) {
            [self playShowAnimationOverActualLoadedData];
        }
    } else if ([self.dataSource showNoItemsLabelIfAppropiateInReportAreaView:self]) {
        [self addSubview:self.noItemsLabel];
    }
}

- (void)playShowAnimationOverActualLoadedData
{
    NSMutableSet *allReportAreaItems = [[NSMutableSet alloc] initWithSet:[self findAllReportAreaItems]];
    for (IAEReportAreaItemView *reportAreaItemView in allReportAreaItems) {
        CGRect frameOfAreaItem = reportAreaItemView.frame;
        reportAreaItemView.frame = CGRectMake(frameOfAreaItem.origin.x, frameOfAreaItem.origin.y + frameOfAreaItem.size.height, frameOfAreaItem.size.width, 0.0);
        
        NSNumber *numberValueOfItem = [[IAECurrencyManager sharedManager].currencyFormatter numberFromString:reportAreaItemView.title.text];
        NSDecimalNumber *decimalNumberOfItem = [NSDecimalNumber decimalNumberWithString:numberValueOfItem.stringValue];
        [reportAreaItemView changeTitleLabel:[[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[NSDecimalNumber zero]]];
        [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:reportAreaItemView.title
                                                                            toValue:decimalNumberOfItem
                                                                       withDuration:kDurationOfReportItemViewAppear];
    
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:kDurationOfReportItemViewDisappear animations:^{
            reportAreaItemView.frame = frameOfAreaItem;
        }];
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
    UIColor *color = [self.dataSource reportAreaView:self colorRepresentationOfItemWithIndex:reportAreaItemIndex];
    IAEReportAreaItemView *reportAreaItem = [[IAEReportAreaItemView alloc] initWithFrame:frameOfReportAreaItem
                                                                                   title:title
                                                                                subtitle:subtitle
                                                                                andColor:color];
    
    return reportAreaItem;
}

- (CGFloat)calculeWidthOfReportAreaItemViews
{
    CGFloat width = (self.bounds.size.width - kXOffsetToStartDrawingReportAreaItems) / kMaxNumberOfReportItemsInScreen;
    
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
        xPosition = kXOffsetToStartDrawingReportAreaItems + reportAreaItemIndex * widthOfReportAreaItemsView;
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
     CGFloat height = maxValue > 0 ? (self.bounds.size.height * valueOfAreaItem) / maxValue : 0;
     
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
