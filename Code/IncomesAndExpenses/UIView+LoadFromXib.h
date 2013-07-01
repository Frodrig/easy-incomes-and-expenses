//
//  UIView+LoadFromXib.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (LoadFromXib)

+ (UIView *)viewFromXib:(NSString *)xibName;

@end
