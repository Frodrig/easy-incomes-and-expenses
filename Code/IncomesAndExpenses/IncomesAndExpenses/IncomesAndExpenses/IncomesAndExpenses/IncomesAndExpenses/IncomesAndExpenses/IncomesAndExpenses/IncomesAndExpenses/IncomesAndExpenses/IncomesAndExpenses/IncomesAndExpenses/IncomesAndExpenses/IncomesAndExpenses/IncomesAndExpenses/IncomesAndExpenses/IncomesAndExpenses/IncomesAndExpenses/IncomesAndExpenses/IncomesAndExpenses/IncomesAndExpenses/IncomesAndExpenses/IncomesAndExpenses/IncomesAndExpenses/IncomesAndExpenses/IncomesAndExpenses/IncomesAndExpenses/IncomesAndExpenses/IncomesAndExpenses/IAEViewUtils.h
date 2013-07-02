//
//  IAEViewUtiils.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEViewUtils : NSObject

+ (void)addRoundedCorners:(NSUInteger)mask withRadius:(CGFloat)radius toView:(UIView *)destView;
+ (UIImage *)colorizeImage:(UIImage *)baseImage color:(UIColor *)theColor;

@end
