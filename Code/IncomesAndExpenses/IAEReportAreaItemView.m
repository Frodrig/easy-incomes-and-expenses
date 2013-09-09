//
//  IAEReportAreaItemView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 29/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEReportAreaItemView.h"

@interface IAEReportAreaItemView()

@property (nonatomic, copy) UIColor *lineColor;
@property (nonatomic, strong) UILabel *subtitle;

@end

@implementation IAEReportAreaItemView

#pragma mark - Constants

static const NSUInteger kXMarginForLabels = 10;

static const CGFloat kWidthForHeightLine = 3.0;

static const CGFloat kHeightForTitleLabel = 24;
static const CGFloat kHeightForSubtitleLabel = 24;
static const CGFloat kMinimumHeightForItem = kHeightForTitleLabel + kHeightForSubtitleLabel;

static NSString * const kTitleFontFamilyName = @"HelveticaNeue-Thin";
static const CGFloat kTitleFontSize = 24;
static const CGFloat kTitleFontKern = 3;
static NSString * const kSubtitleFontFamilyName = @"HelveticaNeue-Thin";
static const CGFloat kSubtitleFontSize = 18;
static const CGFloat kSubtitleFontKern = 2;

static const CGFloat kBackgroundColorWhiteWhiteValue = 0.8;
static const CGFloat kBackgroundColorWithWhiteAlpha = 0.15;
static const CGFloat kTextColorWithWhiteValue = 0;
static const CGFloat kTextColorWithWhiteAlpha = 1.0;


#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    NSAssert(0, @"");
    return nil;
}

- (id)init
{
    NSAssert(0, @"");
    return nil;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    NSAssert(0, @"");
    return nil;
}

- (id)initWithFrame:(CGRect)frame title:(NSString *)title subtitle:(NSString *)subtitle andColor:(UIColor *)color
{
    CGRect adjustedFrame = [self createNewAdjustedFrameToGaranticeMinimumHeightFromFrame:frame];
    self = [super initWithFrame:adjustedFrame];
    if (self) {
        _lineColor = color;
        [self initAndAddTitleLabel:title withColor:color];
        [self initAndAddSubtitleLabel:subtitle withColor:[UIColor colorWithWhite:kTextColorWithWhiteValue alpha:kTextColorWithWhiteAlpha]];
        [self configureBasicProperties];
    }
    
    return self;
}

- (CGRect)createNewAdjustedFrameToGaranticeMinimumHeightFromFrame:(CGRect)frame
{
    CGRect adjustedFrame = frame;
    
    if (kMinimumHeightForItem > frame.size.height) {
        adjustedFrame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height - kMinimumHeightForItem, frame.size.width, kMinimumHeightForItem);
    }

    return adjustedFrame;
}

- (void)configureBasicProperties
{
    self.backgroundColor = [UIColor colorWithWhite:kBackgroundColorWhiteWhiteValue alpha:kBackgroundColorWithWhiteAlpha];
    self.clipsToBounds = NO;
}

- (void)initAndAddTitleLabel:(NSString *)titleString withColor:(UIColor *)color
{
    CGRect labelFrame = CGRectMake(kXMarginForLabels, 0, self.bounds.size.width - kXMarginForLabels, kHeightForTitleLabel);
    _title = [[UILabel alloc] initWithFrame:labelFrame];
    NSDictionary *attributes = [self createLabelAttributesWithFont:kTitleFontFamilyName
                                                              size:kTitleFontSize
                                                             color:color
                                                           andKern:kTitleFontKern];
    _title.attributedText = [[NSAttributedString alloc] initWithString:titleString attributes:attributes];
    _title.adjustsFontSizeToFitWidth = YES;
    _title.backgroundColor = [UIColor clearColor];
    
    [self addSubview:_title];
}

- (void)initAndAddSubtitleLabel:(NSString *)subtitleString withColor:(UIColor *)color
{
    CGRect labelFrame = CGRectMake(kXMarginForLabels, _title.bounds.size.height, self.bounds.size.width - kXMarginForLabels, kHeightForSubtitleLabel);
    _subtitle = [[UILabel alloc] initWithFrame:labelFrame];
    NSDictionary *attributes = [self createLabelAttributesWithFont:kSubtitleFontFamilyName
                                                              size:kSubtitleFontSize
                                                             color:color
                                                           andKern:kSubtitleFontKern];
    _subtitle.attributedText = [[NSAttributedString alloc] initWithString:subtitleString attributes:attributes];
    _subtitle.backgroundColor = [UIColor clearColor];
    _subtitle.lineBreakMode = NSLineBreakByTruncatingTail;
    
    [self addSubview:_subtitle];
}

- (NSDictionary *)createLabelAttributesWithFont:(NSString *)fontFamily size:(CGFloat)size color:(UIColor *)color andKern:(CGFloat)kern
{
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:fontFamily size:size],
                                 NSForegroundColorAttributeName: color,
                                 NSKernAttributeName: @(kern)};
    
    return attributes;
}

#pragma mark - Draw

- (void)drawRect:(CGRect)rect
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    [self drawHeightLineWithContext:contextRef];
}

- (void)drawHeightLineWithContext:(CGContextRef)contextRef
{
    CGContextSaveGState(contextRef);
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, kWidthForHeightLine);
    
    CGContextMoveToPoint(contextRef, 0, 0);
    CGContextAddLineToPoint(contextRef, 0, self.bounds.size.height);
    CGContextSetStrokeColorWithColor(contextRef, self.lineColor.CGColor);

    CGContextStrokePath(contextRef);

    CGContextRestoreGState(contextRef);
}

- (void)changeTitleLabel:(NSString *)title
{
    NSDictionary *attributes = [self createLabelAttributesWithFont:kTitleFontFamilyName
                                                              size:kTitleFontSize
                                                             color:_title.textColor
                                                           andKern:kTitleFontKern];
    _title.attributedText = [[NSAttributedString alloc] initWithString:title attributes:attributes];
}

@end
