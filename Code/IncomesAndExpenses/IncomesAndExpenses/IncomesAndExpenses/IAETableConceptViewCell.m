//
//  IAETableConceptViewCell.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAETableConceptViewCell.h"

@implementation IAETableConceptViewCell

- (void)drawRect:(CGRect)rect
{    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
        
    CGPoint startPointDraw = CGPointMake(self.bounds.origin.x, self.bounds.origin.y + self.bounds.size.height);
    CGPoint endPointDraw = CGPointMake(self.bounds.origin.x + self.bounds.size.width, self.bounds.origin.y + self.bounds.size.height);
    
    const CGFloat dashPattern[] = {2.0, 2.0};
    
    CGContextSetAllowsAntialiasing(contextRef, false);

    CGContextSetLineDash(contextRef, 0, dashPattern, 2);
    CGContextSetLineWidth(contextRef, 2.0);
    CGContextSetRGBStrokeColor(contextRef, 78.0/255.0, 78.0/255.0, 78.0/255.0, 1.0);
    
    CGContextMoveToPoint(contextRef, startPointDraw.x, startPointDraw.y);
    CGContextAddLineToPoint(contextRef, endPointDraw.x, endPointDraw.y);
    
    CGContextStrokePath(contextRef);
    
    CGContextRestoreGState(contextRef);
}

@end
