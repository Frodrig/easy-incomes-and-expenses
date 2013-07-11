//
//  IAEDateHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDateHelper.h"

@implementation IAEDateHelper

+ (NSUInteger)findActualYear
{
    NSDate *actualDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:actualDate];
    
    return dateComponents.year;
}

@end
