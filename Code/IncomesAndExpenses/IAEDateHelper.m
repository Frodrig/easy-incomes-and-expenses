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

+ (NSCalendar *)findCurrentCalendar
{
    static NSCalendar *currentCalendar = nil;
    if (nil == currentCalendar) {
        currentCalendar = [NSCalendar currentCalendar];
    }
    
    return currentCalendar;
}

+ (NSString *)findDayOfTheWeekNameStringWithDayOfTheWeekIndex:(NSUInteger)dayOfTheWeekIndex
{
    static NSArray *dayOfTheWeekNames = nil;
    if (nil == dayOfTheWeekNames) {
        dayOfTheWeekNames = @[NSLocalizedString(@"LTEXT_WEEKDAY_SUNDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_MONDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_TUESDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_WEDNESDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_THURSDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_FRIDAY", @""),
                              NSLocalizedString(@"LTEXT_WEEKDAY_SATURDAY", @"")
                              ];
    }
    
    NSAssert(dayOfTheWeekIndex > 0, @"");
    NSAssert(dayOfTheWeekIndex < 8, @"");
    return [dayOfTheWeekNames objectAtIndex:dayOfTheWeekIndex - 1];
}

+ (NSString *)findMonthNameStringWithMonthIndex:(NSUInteger)monthIndex
{
    static NSArray *monthsNames = nil;
    if (nil == monthsNames) {
        monthsNames = @[NSLocalizedString(@"LTEXT_MONTH_JANUARY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_FEBRUARY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_MARCH", @""),
                        NSLocalizedString(@"LTEXT_MONTH_APRIL", @""),
                        NSLocalizedString(@"LTEXT_MONTH_MAY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_JUNE", @""),
                        NSLocalizedString(@"LTEXT_MONTH_JULY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_AUGUST", @""),
                        NSLocalizedString(@"LTEXT_MONTH_SEPTEMBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_NOVEMBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_OCTOBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_DECEMBER", @"")];
    }
    
    NSAssert(monthIndex > 0, @"");
    NSAssert(monthIndex < 13, @"");
    return [monthsNames objectAtIndex:monthIndex - 1];
}

@end
