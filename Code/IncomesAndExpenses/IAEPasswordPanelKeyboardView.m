//
//  IAEPasswordPanelKeyboardView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 10/12/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordPanelKeyboardView.h"

@implementation IAEPasswordPanelKeyboardView

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
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIGraphicsPushContext(context);
    
    CGContextSetLineWidth(context, 4);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.9 alpha:1].CGColor);
    
    const NSUInteger numberOfRows = 4;
    const NSUInteger rowsSize = self.bounds.size.height / numberOfRows;
    for (NSUInteger rowIt = 0; rowIt < numberOfRows; ++rowIt) {
        const CGFloat yPoint = rowIt * rowsSize;
        CGContextMoveToPoint(context, 0, yPoint);
        CGContextAddLineToPoint(context, self.bounds.size.width, yPoint);
        CGContextStrokePath(context);
    }
    
    UIGraphicsPopContext();
}

@end
