//
//  UIView+LoadFromXib.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/06/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+LoadFromXib.h"

@implementation UIView (LoadFromXib)

+ (UIView *)viewFromXib:(NSString *)xibName withOwner:(id)owner
{
    NSArray *nib = [[NSBundle mainBundle] loadNibNamed:xibName owner:owner options:nil];

    return [nib objectAtIndex:0];
}

@end
