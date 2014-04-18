//
//  IAEEmailChecker.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailChecker.h"

@implementation IAEEmailChecker

+ (BOOL)isValidEmail:(NSString *)emailString
{
    NSString *regExPattern = @"^[A-Z0-9._%+-]+@[A-Z0-9.-]+\\.[A-Z]{2,4}$";
    NSRegularExpression *regEx = [[NSRegularExpression alloc] initWithPattern:regExPattern options:NSRegularExpressionCaseInsensitive error:nil];
    NSUInteger regExMatches = [regEx numberOfMatchesInString:emailString options:0 range:NSMakeRange(0, [emailString length])];
    
    return regExMatches == 0 ? NO : YES;
}

@end
