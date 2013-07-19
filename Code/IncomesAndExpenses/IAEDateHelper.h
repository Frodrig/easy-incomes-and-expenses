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

+ (NSUInteger)findActualYear;

+ (NSString *)findDayOfTheWeekNameStringWithDayOfTheWeekIndex:(NSUInteger)dayOfTheWeekIndex inSortForm:(BOOL)sortForm;

+ (NSString *)findMonthNameStringWithMonthIndex:(NSUInteger)monthIndex;

+ (NSUInteger)findNumberOfDaysOfMonth:(NSUInteger)monthIndex ofYearDate:(NSUInteger)yearDate;
+ (NSUInteger)findFirstDayWeekOfTheMonth:(NSUInteger)monthIndex ofYearDate:(NSUInteger)yearDate;

@end
