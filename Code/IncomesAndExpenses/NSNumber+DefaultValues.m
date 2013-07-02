//
//  NSNumber+DefaultValues.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "NSNumber+DefaultValues.h"

@implementation NSNumber (DefaultValues)

+ (instancetype)numberWithZero
{
    return [NSNumber numberWithFloat:0.0];
}

@end
