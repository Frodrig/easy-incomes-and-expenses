//
//  IAENibUtils.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/09/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAENibUtils.h"

@implementation IAENibUtils

+ (CGSize)findSizeOfTheBaseViewOfNibNamed:(NSString *)nibName
{
    NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
    UIView *baseView = [nibContents lastObject];
    CGSize size = CGSizeMake(baseView.bounds.size.width, baseView.bounds.size.height);

    return size;
}


@end
