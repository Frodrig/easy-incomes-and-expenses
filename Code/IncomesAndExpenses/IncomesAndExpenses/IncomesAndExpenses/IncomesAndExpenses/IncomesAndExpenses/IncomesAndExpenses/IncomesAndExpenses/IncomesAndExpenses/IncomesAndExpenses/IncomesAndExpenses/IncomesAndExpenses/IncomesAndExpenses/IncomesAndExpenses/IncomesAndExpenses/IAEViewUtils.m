//
//  IAEViewUtiils.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEViewUtils.h"
#include <QuartzCore/QuartzCore.h>

@implementation IAEViewUtils

+ (void)addRoundedCorners:(NSUInteger)mask withRadius:(CGFloat)radius toView:(UIView *)destView
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:destView.bounds
                                                   byRoundingCorners:mask
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = destView.bounds;
    maskLayer.path = maskPath.CGPath;
    
    destView.layer.mask = maskLayer;
}

+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor {
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContext(baseImage.size);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [theColor setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, baseImage.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeColorBurn);
    CGRect rect = CGRectMake(0, 0, baseImage.size.width, baseImage.size.height);
    CGContextDrawImage(context, rect, baseImage.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, baseImage.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
}

@end
