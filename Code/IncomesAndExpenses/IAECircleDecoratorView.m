//
//  IAECircleDecoratorView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 15/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECircleDecoratorView.h"

@implementation IAECircleDecoratorView

#pragma mark - Setters

// Nota: Extraño que no haga el synthesize automaticamente al sobreescribir los getters y setters
@synthesize circleColor = _circleColor;

- (void)setCircleColor:(UIColor *)circleColor
{
    if (circleColor) {
        _circleColor = [circleColor copy];
        [self setNeedsDisplay];
    }
}

- (UIColor *)circleColor
{
    if (!_circleColor) {
        _circleColor = [UIColor colorWithWhite:0.85 alpha:1.0];
    }
    
    return _circleColor;
}

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
    [super drawRect:rect];
    
    [self drawCircleDecorator];
}

- (void)drawCircleDecorator
{
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    CGContextSaveGState(contextRef);
    
    const CGFloat radius = MIN(self.bounds.size.width, self.bounds.size.height) / 3.0;
    const CGFloat twoPiRadians = 6.28318531;
    const CGPoint center = CGPointMake(self.bounds.size.width / 2.0, self.bounds.size.height / 2.0);

    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 1.0);
    CGContextSetFillColorWithColor(contextRef, self.circleColor.CGColor);
    CGContextAddArc(contextRef, center.x, center.y, radius, 0, twoPiRadians, 1);
    CGContextFillPath(contextRef);

    CGContextRestoreGState(contextRef);
}


@end
