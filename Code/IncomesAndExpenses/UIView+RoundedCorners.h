//
//  UIView+RoundedCorners.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RoundedCorners)

- (void)addRoundedCorners:(NSUInteger)mask withRadius:(CGFloat)radius;
- (void)clearRoundedCorners;


@end
