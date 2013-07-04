//
//  IAEEditModeConceptCollectionViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEditModeConceptCollectionViewCell.h"
#import "IAEValueDecoratorView.h"

@interface IAEEditModeConceptCollectionViewCell()


@end

@implementation IAEEditModeConceptCollectionViewCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self drawBottomDotLine];
}

- (void)drawBottomDotLine
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    CGFloat marginX = 20.0;
    CGFloat marginY = 0;
    CGFloat originInX = marginX + 0;
    CGPoint startPointDraw = CGPointMake(originInX, self.bounds.origin.y + self.bounds.size.height - marginY);
    CGPoint endPointDraw = CGPointMake(originInX + self.bounds.size.width - marginX, startPointDraw.y);
    
    const CGFloat dashPattern[] = {1.0, 6.0};
    
    CGContextSetAllowsAntialiasing(contextRef, false);
    
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetRGBStrokeColor(contextRef, 207.0/255.0, 207.0/255.0, 207.0/255.0, 1.0);
    
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

@end
