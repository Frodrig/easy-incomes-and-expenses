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

@implementation IAEReportAreaView

static CGFloat widthForLines = 1.0;
static CGFloat colorWithWhiteValueForLines = 0.5;
static CGFloat alphaForColorWithWhiteValueForLines = 1.0;

@synthesize delegate = delegate__;

- (void)setDelegate:(id<IAEReportAreaViewDelegate>)delegate
{
    if (delegate != delegate__) {
        [super setDelegate:delegate];
        delegate__ = delegate;
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
    CGContextSetLineWidth(contextRef, widthForLines);
    
    CGContextMoveToPoint(contextRef, fromPoint.x, fromPoint.y);
    CGContextAddLineToPoint(contextRef, destinationPoint.x, destinationPoint.y);
    CGContextSetGrayStrokeColor(contextRef, colorWithWhiteValueForLines, alphaForColorWithWhiteValueForLines);
    CGContextStrokePath(contextRef);

    CGContextRestoreGState(contextRef);
}

#pragma mark - Reload

- (void)reloadData
{
    
}

@end
