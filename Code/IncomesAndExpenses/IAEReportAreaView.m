//
//  IAEReportAreaView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEReportAreaView.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEReportAreaViewDataSource.h"
#import "IAEReportAreaItemView.h"
#import "IAEEconomicValueUpdater.h"
#import "IAECurrencyManager.h"
#import "IAEReportAreaViewDelegate.h"

@interface IAEReportAreaView()

@property (nonatomic, strong) UILabel *noItemsLabel;
@property (nonatomic, strong) NSMutableDictionary *reloadPendingInformation;
@property (nonatomic, readonly) BOOL showingAllReportAreaItems;
@property (nonatomic, strong) NSMutableSet *allReportAreaItems;
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;

@end

@implementation IAEReportAreaView

#pragma mark - Constants

static NSString * const kUserDefaultsReportAmountMode = @"reportAmountMode";
static NSString * const kUserDefaultsReportAmountModeTotalAmountValue = @"totalAmounts";
static NSString * const kUserDefaultsReportAmountModePercentageAmountValue = @"percentageAmounts";

static NSString * const kLTextReportAreaItemsNoItemsWarning = @"LTEXT_REPORTAREAITEMS_NOITEMSWARNING";
static NSString * const kReportAreaItemsNoItemsWarningFontName = @"HelveticaNeue-Ultralight";
static const CGFloat kReportAreaItemsNoItemsFontSize = 36;
static const CGFloat kReportAreaItemsNoItemsWarningKern = 0;

static const CGFloat kXOffsetToStartDrawingReportAreaItems = 0;

static const CGFloat kWidthForLines = 1.0;
static const CGFloat kColorWithWhiteValueForLines = 0.5;
static const CGFloat kAlphaForColorWithWhiteValueForLines = 1.0;

static const CGFloat kMaxNumberOfReportItemsInScreen = 4;

static const CGFloat kDurationOfReportItemViewAppear = 0.75;
static const CGFloat kDurationOfReportItemViewDisappear = 0.75;

static const CGFloat kMinAlphaValueForScrolledReportAreaItems = 0.15;

static NSString * const kReloadPendingKey = @"ReloadPending";

static const CGFloat KDurationOfNoItemsLabelAnimations = 0.5;

#pragma mark - Properties

- (NSMutableSet *)allReportAreaItems
{
    if (!_allReportAreaItems) {
        _allReportAreaItems = [[NSMutableSet alloc] init];
    }
    
    return _allReportAreaItems;
}

- (NSDictionary *)reloadPendingInformation
{
    if (!_reloadPendingInformation) {
        _reloadPendingInformation = [[NSMutableDictionary alloc] init];
    }
    
    return _reloadPendingInformation;
}

- (UILabel *)noItemsLabel
{
    if (!_noItemsLabel) {
        _noItemsLabel = [[UILabel alloc] initWithFrame:self.bounds];
        UIFont *fontForText = [UIFont fontWithName:kReportAreaItemsNoItemsWarningFontName size:kReportAreaItemsNoItemsFontSize];
        NSDictionary *attributesForText = @{NSFontAttributeName: fontForText,
                                            NSForegroundColorAttributeName: [UIColor blackColor],
                                            NSKernAttributeName: @(kReportAreaItemsNoItemsWarningKern)};
        _noItemsLabel.attributedText = [[NSAttributedString alloc] initWithString:NSLocalizedString(kLTextReportAreaItemsNoItemsWarning, @"")
                                                                       attributes:attributesForText];
        _noItemsLabel.textAlignment = NSTextAlignmentCenter;
        _noItemsLabel.backgroundColor = [UIColor clearColor];
    }
    
    return _noItemsLabel;
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

#pragma mark - Dealloc

- (void)dealloc
{
    [self removeGestureRecognizer:self.tapGestureRecognizer];
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initScrollViewProperties];
        [self initTapGestureRecognizer];
        
        self.delegate = self;
    }
    return self;
}

- (void)initScrollViewProperties
{
    self.pagingEnabled = NO;
    self.bounces = YES;
    self.alwaysBounceHorizontal = YES;
    self.alwaysBounceVertical = NO;
    self.scrollEnabled = YES;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
}

- (void)initTapGestureRecognizer
{
    _tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(processTapGesture:)];
    [self addGestureRecognizer:_tapGestureRecognizer];
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
    if (!self.reloadInProgress) {
        [self removeAllReportAreaItemsWithAnimation:NO andExecuteBlockAtCompletion:nil];
        [self adjustContentSizeAndResetPosition];
    }
}

- (void)reloadDataWithAnimation:(BOOL)animation
{
    if (!self.reloadInProgress && !self.showingAllReportAreaItems) {
        [self beginReloadDataWithAnimation];
        [self removeAllReportAreaItemsWithAnimation:animation andExecuteBlockAtCompletion:^(void) {
            [self createAndAddAllReportAreaItemsIfAppropiateWithAnimation:animation];
            [self adjustContentSizeAndResetPosition];
        }];
    } else if (self.showingAllReportAreaItems) {
        self.reloadPendingInformation[kReloadPendingKey] = [NSNumber numberWithBool:animation];
    }
}

- (void)beginReloadDataWithAnimation
{
    _reloadInProgress = YES;
    self.scrollEnabled = NO;
}

- (void)endReloadDataWithAnimation
{
    _reloadInProgress = NO;
    self.scrollEnabled = !_showingAllReportAreaItems;
    [self.reportAreaViewDelegate reloadDataWithAnimationWasDoneInReportAreaView:self];
}

- (void)processPendingReloads
{
    NSNumber *pendingReloadDataWithAnimationValue = self.reloadPendingInformation[kReloadPendingKey];
    if (pendingReloadDataWithAnimationValue) {
        [self.reloadPendingInformation removeAllObjects];
        [self reloadDataWithAnimation:pendingReloadDataWithAnimationValue.boolValue];
    }
}

- (void)removeAllReportAreaItemsWithAnimation:(BOOL)animation andExecuteBlockAtCompletion:(void(^)(void))block
{
    __block NSUInteger numberOfAreaItemsToRemove = self.allReportAreaItems.count;
    if (numberOfAreaItemsToRemove > 0) {
        for (IAEReportAreaItemView *reportAreaItemView in self.allReportAreaItems) {
            if (animation) {
                
                // ToDo
                /*
                [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:reportAreaItemView.title
                                                                                    toValue:[NSDecimalNumber zero]
                                                                               withDuration:kDurationOfReportItemViewDisappear];
                */
                
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
        
        [self.allReportAreaItems removeAllObjects];
    } else {
        if (block) {
            block();
        }
    }
}

- (void)createAndAddAllReportAreaItemsIfAppropiateWithAnimation:(BOOL)animation
{
    NSUInteger numberOfReportAreaItems = [self.dataSource numberOfItemsInReportAreaView:self];
    if (numberOfReportAreaItems > 0) {
        [self.dataSource reloadAllItemsWillBeginInReportAreaView:self];
       
        [self endReloadDataWithAnimation];
        [self showNoItemsLabel:NO withAnimation:animation completion:nil];
        
        for (NSUInteger reportAreaItemIt = 0; reportAreaItemIt < numberOfReportAreaItems; reportAreaItemIt++) {
            IAEReportAreaItemView *reportAreaItem = [self createReportAreaItemWithIndex:reportAreaItemIt ofTotalNumber:numberOfReportAreaItems];
            [self addSubview:reportAreaItem];
            [self.allReportAreaItems addObject:reportAreaItem];
        }
        
        [self.dataSource reloadAllItemsDidEndInReportAreaView:self];

        if (animation) {
            [self playShowAnimationOverActualLoadedData];
        }
    } else if ([self.dataSource showNoItemsLabelIfAppropiateInReportAreaView:self]) {
        [self showNoItemsLabel:YES withAnimation:animation completion:^{
            [self endReloadDataWithAnimation];
        }];
    } else {
        [self showNoItemsLabel:NO withAnimation:animation completion:^{
            [self endReloadDataWithAnimation];
        }];
    }
}

- (void)showNoItemsLabel:(BOOL)show withAnimation:(BOOL)animation completion:(void(^)(void))completionBlock
{
    const BOOL ignoreBecouseSameState = show ? self.noItemsLabel.superview == self && self.noItemsLabel.alpha == 1.0 : self.noItemsLabel.superview == nil;
    
    if (!ignoreBecouseSameState) {
        if (animation) {
            [self addSubview:self.noItemsLabel];
            self.noItemsLabel.alpha = show ? 0.0 : 1.0;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView animateWithDuration:KDurationOfNoItemsLabelAnimations animations:^{
                self.noItemsLabel.alpha = show ? 1.0 : 0.0;
            } completion:^(BOOL finished) {
                if (completionBlock) {
                    completionBlock();
                }
                if (!show) {
                    [self.noItemsLabel removeFromSuperview];
                }
            }];
        } else {
            self.noItemsLabel.alpha = 1.0;
            if (show) {
                [self addSubview:self.noItemsLabel];
            } else {
                [self.noItemsLabel removeFromSuperview];
            }
            if (completionBlock) {
                completionBlock();
            }
        }
    } else {
        if (completionBlock) {
            completionBlock();
        }
    }
}

- (void)beginShowingAllReportAreaItems
{
    _showingAllReportAreaItems = YES;
    self.scrollEnabled = NO;
}

- (void)endShowingAllReportAreaItems
{
    _showingAllReportAreaItems = NO;
    self.scrollEnabled = !_reloadInProgress;
}

- (void)playShowAnimationOverActualLoadedData
{
    __block NSUInteger numberOfReportAreaItemsPending = self.allReportAreaItems.count;
    if (numberOfReportAreaItemsPending > 0) {
        [self beginShowingAllReportAreaItems];
        
        for (IAEReportAreaItemView *reportAreaItemView in self.allReportAreaItems) {
            CGRect frameOfAreaItem = reportAreaItemView.frame;
            reportAreaItemView.frame = CGRectMake(frameOfAreaItem.origin.x, frameOfAreaItem.origin.y + frameOfAreaItem.size.height, frameOfAreaItem.size.width, 0.0);
            
            // ToDo
            [reportAreaItemView changeTitleLabel:reportAreaItemView.title.text];

            /*
            NSNumber *numberValueOfItem = [[IAECurrencyManager sharedManager].currencyFormatter numberFromString:reportAreaItemView.title.text];
            NSDecimalNumber *decimalNumberOfItem = [NSDecimalNumber decimalNumberWithString:numberValueOfItem.stringValue];
            
            [reportAreaItemView changeTitleLabel:[[IAECurrencyManager sharedManager].currencyFormatter stringFromNumber:[NSDecimalNumber zero]]];
            [[IAEEconomicValueUpdater defaultEconomicValueUpdater] processEconomicLabel:reportAreaItemView.title
                                                                                toValue:decimalNumberOfItem
                                                                           withDuration:kDurationOfReportItemViewAppear];
             */
             
            
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:kDurationOfReportItemViewDisappear animations:^{
                reportAreaItemView.frame = frameOfAreaItem;
            } completion:^(BOOL finished) {
                --numberOfReportAreaItemsPending;
                if (0 == numberOfReportAreaItemsPending) {
                    [self endShowingAllReportAreaItems];
                    [self processPendingReloads];
                }
            }];
        }
    } else {
        [self endReloadDataWithAnimation];
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
    reportAreaItem.tag = [self createReportAreaItemTagForIndex:reportAreaItemIndex];
    
    return reportAreaItem;
}

- (NSUInteger)createReportAreaItemTagForIndex:(NSUInteger)index
{
    static const NSUInteger kBaseTag = 699;
    const NSUInteger tag = kBaseTag + index;
    
    return tag;
    
}

- (CGFloat)calculeWidthOfReportAreaItemViews
{
    const CGFloat width = (self.bounds.size.width - kXOffsetToStartDrawingReportAreaItems) / kMaxNumberOfReportItemsInScreen;
    
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
    NSAssert(totalNumber > 0, @"");
    const NSUInteger widthTotalInterSpace = MAX(0, self.bounds.size.width - (widthOfReportAreaItemsView * totalNumber));
    const NSUInteger widthUnitInterSpace = totalNumber < kMaxNumberOfReportItemsInScreen ? widthTotalInterSpace / (totalNumber + 1): 0;
    const CGFloat xPosition = widthUnitInterSpace + reportAreaItemIndex * (widthOfReportAreaItemsView + widthUnitInterSpace);
    
    return xPosition;
}

- (CGFloat)calculeHeightOfReportAreaItemWithMaxValue:(CGFloat)maxValue andReportAreaItemValue:(CGFloat)valueOfAreaItem
 {
     CGFloat height = maxValue > 0 ? (self.bounds.size.height * (valueOfAreaItem / maxValue)) : 0;
     
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

#pragma mark - Gesture Recognizer

- (void)processTapGesture:(UITapGestureRecognizer *)tapGestureRecognizer
{
    if ([self canChangeActualReportAmountMode]) {
        [self.dataSource changeActualReportAmountModeWillOcurrInReportAreaView:self];
        
        [[NSUserDefaults standardUserDefaults] changeToNextReportMode];
        
        for (NSUInteger reportAreaItemIt = 0; reportAreaItemIt < self.allReportAreaItems.count; ++reportAreaItemIt) {
            NSString *title = [self.dataSource reportAreaView:self titleOfItemWithIndex:reportAreaItemIt];
            
            IAEReportAreaItemView *reportAreaItem = (IAEReportAreaItemView *)[self viewWithTag:[self createReportAreaItemTagForIndex:reportAreaItemIt]];
            [reportAreaItem changeTitleLabel:title];
        }
        
        [self.dataSource changeActualReportAmountModeDidOcurrInReportAreaView:self];
    }
}

#pragma mark - Mode

- (BOOL)canChangeActualReportAmountMode
{
    const BOOL canChange = [self.dataSource canChangeActualReportAmountModeInReportAreaView:self] && self.allReportAreaItems.count > 0;
    
    return canChange;
}

#pragma mark - UIScrollViewDelegate

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    const NSUInteger numberOfReportAreaItems = self.allReportAreaItems.count;
    const CGFloat widthOfAreaItemsView = [self calculeWidthOfReportAreaItemViews];
    const CGFloat maxNumberOfAreaItemsViewFullPresented = scrollView.frame.size.width / widthOfAreaItemsView;
    const BOOL performScrollDissolveFx = numberOfReportAreaItems > maxNumberOfAreaItemsViewFullPresented;
    
    if (performScrollDissolveFx) {
        const CGFloat normalizedIndex = scrollView.contentOffset.x / widthOfAreaItemsView;
        const CGFloat positiveNormalizedIndex = MAX(normalizedIndex, 0);
        const CGFloat normalizedOffset = ceilf(normalizedIndex) - positiveNormalizedIndex;
        const NSUInteger leftViewIndex = MAX(floorf(positiveNormalizedIndex), 0);
        const NSUInteger rightViewIndex = leftViewIndex + MIN(maxNumberOfAreaItemsViewFullPresented, numberOfReportAreaItems - 1);
        const BOOL onlyMaxNumberOfAreaIemsViewFullyPresented = normalizedOffset == 0;
        
        // Extremos
        const CGFloat alphaForLeftReportAreaItemView = onlyMaxNumberOfAreaIemsViewFullyPresented ? 1.0 : MAX(normalizedOffset, kMinAlphaValueForScrolledReportAreaItems);
        [self findReportAreaItemWithTag:[self createReportAreaItemTagForIndex:leftViewIndex]].alpha = alphaForLeftReportAreaItemView;
        //[self viewWithTag:[self createReportAreaItemTagForIndex:leftViewIndex]].alpha = alphaForLeftReportAreaItemView;
        if (rightViewIndex < numberOfReportAreaItems) {
            const CGFloat alphaForRightReportAreaItemView = onlyMaxNumberOfAreaIemsViewFullyPresented ? 0.0 : MAX(1 - normalizedOffset, kMinAlphaValueForScrolledReportAreaItems);
            [self findReportAreaItemWithTag:[self createReportAreaItemTagForIndex:rightViewIndex]].alpha = alphaForRightReportAreaItemView;
            //[self viewWithTag:[self createReportAreaItemTagForIndex:rightViewIndex]].alpha = alphaForRightReportAreaItemView;
        }
        
        // izquierda extremo izquierdo, medio, derecha extremo derecho
        for (NSUInteger restOfAreaItemsViewIt = 0; restOfAreaItemsViewIt < numberOfReportAreaItems; ++restOfAreaItemsViewIt) {
            if (restOfAreaItemsViewIt < leftViewIndex || restOfAreaItemsViewIt > rightViewIndex) {
                [self findReportAreaItemWithTag:[self createReportAreaItemTagForIndex:restOfAreaItemsViewIt]].alpha = kMinAlphaValueForScrolledReportAreaItems;
                //[self viewWithTag:[self createReportAreaItemTagForIndex:restOfAreaItemsViewIt]].alpha = kMinAlphaValueForScrolledReportAreaItems;
            } else if (restOfAreaItemsViewIt > leftViewIndex && restOfAreaItemsViewIt < rightViewIndex) {
                [self findReportAreaItemWithTag:[self createReportAreaItemTagForIndex:restOfAreaItemsViewIt]].alpha = 1.0;
                //[self viewWithTag:[self createReportAreaItemTagForIndex:restOfAreaItemsViewIt]].alpha = 1.0;
            }
        }
    }
}

- (IAEReportAreaItemView *)findReportAreaItemWithTag:(NSUInteger)tag
{
    IAEReportAreaItemView *reportAreaItem = nil;
    
    [self.allReportAreaItems objectsPassingTest:^BOOL(id obj, BOOL *stop) {
        IAEReportAreaItemView *reportAreaItemIt = obj;
        *stop = reportAreaItemIt.tag == tag;
        if (*stop) {
            reportAreaItemIt = reportAreaItemIt;
        }
        
        return YES;
    }];
    
    return reportAreaItem;
}
 */

@end
