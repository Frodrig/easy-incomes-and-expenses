//
//  NSString+TwoDigitString.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "NSString+TwoDigitString.h"

@implementation NSString (TwoDigitString)

+ (NSString *)stringWithAtLastTwoDigitFromNumber:(NSNumber *)number
{
    NSString *retNumber = number.unsignedIntegerValue < 10 ? [@"0" stringByAppendingString:number.stringValue] : number.stringValue;
    return retNumber;
}

@end
