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

static const CGFloat kWhiteColorComponentForCircle = 0.85;
static const CGFloat kWhiteAlphaComponentForCircle = 1.0;

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
        _circleColor = [UIColor colorWithWhite:kWhiteColorComponentForCircle
                                         alpha:kWhiteAlphaComponentForCircle];
    }
    
    return _circleColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initValues];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initValues];
    }
    
    return self;
}

- (void)initValues
{
    _radiusScale = 1.0;
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
    
    const CGFloat radius = (MIN(self.bounds.size.width, self.bounds.size.height) / 2) * self.radiusScale;
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
