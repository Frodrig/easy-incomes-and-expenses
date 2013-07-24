//
//  IAEDateHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDateHelper.h"

@implementation IAEDateHelper

+ (NSUInteger)findActualYearDate
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

+ (NSString *)findDayOfTheWeekNameStringWithDayOfTheWeekIndex:(NSUInteger)dayOfTheWeekIndex inShortForm:(BOOL)sortForm;
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
    NSString *name = [dayOfTheWeekNames objectAtIndex:dayOfTheWeekIndex - 1];
    
    if (sortForm) {
        name = [name substringWithRange:NSMakeRange(0, 3)];
        name = [name lowercaseString];
    }
    
    return name;
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

+ (NSUInteger)findDayOfTheWeekIndexFromYearDate:(NSUInteger)yearDate
                                     monthIndex:(NSUInteger)monthIndex
                               andDayOfTheMonth:(NSUInteger)dayOfTheMonth
{
    NSDateComponents *dateComponents = [self createDateComponentsForDay:dayOfTheMonth month:monthIndex andYearDate:yearDate];
    NSDate *date = [[self findCurrentCalendar] dateFromComponents:dateComponents];
    NSDateComponents *dateComponentsWithWeekDay = [[self findCurrentCalendar] components:NSWeekdayCalendarUnit fromDate:date];
    
    return dateComponentsWithWeekDay.weekday;
}

+ (NSUInteger)findNumberOfDaysFromYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex
{
    NSDateComponents *dateComponents = [self createDateComponentsFromYearDate:yearDate andMonthIndex:monthIndex];
    NSDate *date = [[self findCurrentCalendar] dateFromComponents:dateComponents];
    NSRange rangeDaysOfMonth = [[self findCurrentCalendar] rangeOfUnit:NSDayCalendarUnit inUnit:NSMonthCalendarUnit forDate:date];
    
    return rangeDaysOfMonth.length;
}

+ (NSUInteger)findFirstDayWeekFromYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex 
{
    NSDateComponents *dateComponents = [self createDateComponentsFromYearDate:yearDate andMonthIndex:monthIndex];
    NSDate *date = [[self findCurrentCalendar] dateFromComponents:dateComponents];
    NSUInteger firstWeekDay = [[self findCurrentCalendar] ordinalityOfUnit:NSWeekdayCalendarUnit inUnit:NSWeekCalendarUnit forDate:date];
    
    return firstWeekDay;
}

+ (NSDateComponents *)createDateComponentsForDay:(NSUInteger)day month:(NSUInteger)monthIndex andYearDate:(NSUInteger)yearDate
{
    NSDateComponents *dateComponents = [self createDateComponentsFromYearDate:yearDate andMonthIndex:monthIndex];
    dateComponents.day = day;
    
    return dateComponents;
}

+ (NSDateComponents *)createDateComponentsFromYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = yearDate;
    dateComponents.month = monthIndex;
    dateComponents.day = 1;
    
    return dateComponents;
}


@end
