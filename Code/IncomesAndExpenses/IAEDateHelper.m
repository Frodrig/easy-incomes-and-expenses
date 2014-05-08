//
//  IAEDateHelper.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEDateHelper.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@implementation IAEDateHelper

+ (NSUInteger)findActualYearDate
{
    NSDate *actualDate = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSYearCalendarUnit fromDate:actualDate];
    
    return dateComponents.year;
}

+ (NSUInteger)findActualDayOfTheMonth
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents* components = [calendar components:NSDayCalendarUnit fromDate:[NSDate date]];
    return [components day];
}

+ (NSCalendar *)findCurrentCalendar
{
    static NSCalendar *currentCalendar = nil;
    if (!currentCalendar) {
        currentCalendar = [NSCalendar currentCalendar];
    }
    
    return currentCalendar;
}

+ (NSString *)findDayOfTheWeekNameStringWithDayOfTheWeekIndex:(NSUInteger)dayOfTheWeekIndex inShortForm:(BOOL)shortForm;
{
    static NSArray *dayOfTheWeekNames = nil;
    if (!dayOfTheWeekNames) {
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
    
    if (shortForm) {
        name = [self createShortFormOfName:name];
    }
    
    return name;
}

+ (NSString *)findMonthNameStringWithMonthIndex:(NSUInteger)monthIndex inShortForm:(BOOL)shortForm
{
    static NSArray *monthsNames = nil;
    if (!monthsNames) {
        monthsNames = @[NSLocalizedString(@"LTEXT_MONTH_JANUARY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_FEBRUARY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_MARCH", @""),
                        NSLocalizedString(@"LTEXT_MONTH_APRIL", @""),
                        NSLocalizedString(@"LTEXT_MONTH_MAY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_JUNE", @""),
                        NSLocalizedString(@"LTEXT_MONTH_JULY", @""),
                        NSLocalizedString(@"LTEXT_MONTH_AUGUST", @""),
                        NSLocalizedString(@"LTEXT_MONTH_SEPTEMBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_OCTOBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_NOVEMBER", @""),
                        NSLocalizedString(@"LTEXT_MONTH_DECEMBER", @"")];
    }
    
    NSAssert(monthIndex > 0, @"");
    NSAssert(monthIndex < 13, @"");
    NSString *name = [monthsNames objectAtIndex:monthIndex - 1];
    if (shortForm) {
        name = [self createShortFormOfName:name];
    }
    
    return name;
}

+ (NSString *)createShortFormOfName:(NSString *)name
{
    name = [name substringWithRange:NSMakeRange(0, 3)];
    name = [name lowercaseString];
    
    return name;
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

+ (NSString *)createYearIdentificationTagFromYearDate:(NSUInteger)yearDate withShortForm:(BOOL)shortForm
{
    NSString *yearString = nil;
    
    const MonthType initialMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
    const BOOL usingTwoYears = initialMonth != January;
    if (usingTwoYears) {
        NSString *firstYearString = [NSString stringWithFormat:@"%lu", (unsigned long)yearDate];
        NSString *secondYearString = [NSString stringWithFormat:@"%lu", (unsigned long)(yearDate + 1)];
        if (shortForm) {
            firstYearString = [firstYearString substringWithRange:NSMakeRange(2, 2)];
            secondYearString = [secondYearString substringWithRange:NSMakeRange(2, 2)];
        }
        yearString = [NSString stringWithFormat:@"%@/%@", firstYearString, secondYearString];
    } else {
        yearString = [NSString stringWithFormat:@"%lu", (unsigned long)yearDate];
    }
    
    return yearString;
}

+ (NSArray *)monthTypesArray
{
    static NSArray *monthTypes = nil;

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        monthTypes = @[@(January),
                       @(February),
                       @(March),
                       @(April),
                       @(May),
                       @(June),
                       @(July),
                       @(August),
                       @(September),
                       @(October),
                       @(November),
                       @(December)];
    });

    return monthTypes;
}


@end
