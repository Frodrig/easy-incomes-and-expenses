//
//  NSDecimalNumber+AbsoluteValue.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "NSDecimalNumber+AbsoluteValue.h"

@implementation NSDecimalNumber (AbsoluteValue)

- (NSDecimalNumber *)decimalNumberByAbsoluteValue
{
    NSDecimalNumber *mirrorValue = [self decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1.0"]];
    if ([mirrorValue compare:self] == NSOrderedDescending) {
        return mirrorValue;
    }
    
    return [self copy];
}

@end
