//
//  IAEDateHelper.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 11/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEDateHelper : NSObject

+ (NSCalendar *)findCurrentCalendar;

+ (NSUInteger)findActualYearDate;
+ (NSUInteger)findActualDayOfTheMonth;

+ (NSString *)findDayOfTheWeekNameStringWithDayOfTheWeekIndex:(NSUInteger)dayOfTheWeekIndex inShortForm:(BOOL)sortForm;
+ (NSUInteger)findDayOfTheWeekIndexFromYearDate:(NSUInteger)yearDate monthIndex:(NSUInteger)monthIndex andDayOfTheMonth:(NSUInteger)dayOfTheMonth;

+ (NSString *)findMonthNameStringWithMonthIndex:(NSUInteger)monthIndex inShortForm:(BOOL)shortForm;

+ (NSUInteger)findNumberOfDaysFromYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex;
+ (NSUInteger)findFirstDayWeekFromYearDate:(NSUInteger)yearDate andMonthIndex:(NSUInteger)monthIndex;

+ (NSString *)createYearIdentificationTagFromYearDate:(NSUInteger)yearDate withShortForm:(BOOL)shortForm;

+ (NSArray *)monthTypesArray;

@end
