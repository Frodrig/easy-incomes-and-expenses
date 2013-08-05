//
//  IAENumberUtils.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAENumberUtils.h"

@implementation IAENumberUtils

+ (NSDecimalNumber *)maxValueOfNumber:(NSDecimalNumber *)numberOne andNumber:(NSDecimalNumber *)numberTwo
{
    NSDecimalNumber *maxValue = [numberOne compare:numberTwo] == NSOrderedDescending ? numberOne : numberTwo;
    
    return maxValue;
}

@end
