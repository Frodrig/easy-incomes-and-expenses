//
//  UIView+RoundedCorners.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+RoundedCorners.h"
#import <QuartzCore/QuartzCore.h>

@implementation UIView (RoundedCorners)

- (void)addRoundedCorners:(NSUInteger)mask withRadius:(CGFloat)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:mask
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    self.layer.mask = maskLayer;
}

- (void)clearRoundedCorners
{
    self.layer.mask = nil;
}

@end
