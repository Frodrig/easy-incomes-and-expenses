//
//  IAEDragToolbarView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDragToolbarView.h"

@implementation IAEDragToolbarView

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    CGPoint beginingPoint = CGPointMake(self.bounds.origin.x + self.bounds.size.width / 2, 4.0);

    CGContextSetAllowsAntialiasing(contextRef, false);

    CGContextSetRGBStrokeColor(contextRef, 0.0, 0.0, 0.0, 0.5);
    CGContextSetLineWidth(contextRef, 1.0);
    
    for (NSUInteger i = 0; i < 3; i++)
    {
        CGPoint startPointDraw = CGPointMake(beginingPoint.x - 20.0, beginingPoint.y + i * 3.0);
        CGPoint endPointDraw = CGPointMake(beginingPoint.x + 20.0, beginingPoint.y + i * 3.0);
    
        CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
        CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
        CGContextSetShadowWithColor(contextRef, CGSizeMake(0, 0.5), 0.0, [UIColor colorWithRed:175.0/255.0 green:175.0/255.0 blue:175.0/255.0 alpha:1.0].CGColor);
    }
    
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

- (void)dealloc
{
    self.layer.mask = nil;
}

@end
