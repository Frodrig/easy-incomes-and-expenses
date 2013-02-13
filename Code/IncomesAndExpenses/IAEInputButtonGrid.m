//
//  IAEInputButtonGrid.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInputButtonGrid.h"

@implementation IAEInputButtonGrid

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.

- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    // Lineas verticales
    const CGFloat offsetX = self.bounds.size.width / 4.0;
    
    CGContextSetAllowsAntialiasing(contextRef, false);
    
    CGContextSetRGBStrokeColor(contextRef, 55.0/255.0, 55.0/255.0, 55.0/255.0, 1.0);
    CGContextSetShadow(contextRef, CGSizeMake(0.0, 0.0), 0);
    CGContextSetLineWidth(contextRef, 0.1);
    
    for (NSUInteger i = 0; i < 3; i++)
    {
        CGFloat xOrigin = self.bounds.origin.x + offsetX * (i + 1);
        
        CGPoint startPointDraw = CGPointMake(xOrigin, self.bounds.origin.y + 5.0);
        CGPoint endPointDraw = CGPointMake(xOrigin, self.bounds.origin.y + self.bounds.size.height - 5.0);
        
        CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
        CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    }
    
    CGContextStrokePath(contextRef);

    // Lineas horizontales
    const CGFloat offsetY = self.bounds.size.height / 3.0;
    
    const CGFloat dashPattern[] = {offsetX * 0.8, offsetX * 0.2};
    
    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    
    for (NSUInteger i = 0; i < 2; i++)
    {
        CGFloat yOrigin = self.bounds.origin.y + offsetY * (i + 1);
        
        CGPoint startPointDraw = CGPointMake(self.bounds.origin.x + 10.0, self.bounds.origin.y + yOrigin);
        CGPoint endPointDraw = CGPointMake(self.bounds.origin.x + self.bounds.size.width - 10.0, self.bounds.origin.y + yOrigin);
        
        CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
        CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    }
    
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

- (void)dealloc
{
    self.layer.mask = nil;
}

@end
