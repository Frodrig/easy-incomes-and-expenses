//
//  IAEExporterConverter.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//
// Formato:
//
// "selectedMonths": @[IAEMonth]
// "totals". {"balance": NSDecimal, "expenses": NSDecimal, "incomes": NSDecimal}
// "incomesByCategory", {categoryTag: value}
// "expensesByCategory", {categoryTag: value}
// "totalsByMonth", {idxMonth: {"self": IAEMonth, "balance": NSDecimalNumber, "expenses": NSDecimalNumber, "incomes": NSDecimalNumber}}
// "incomesByMonthAndCategories", {idxMonth: {"self": IAEMonth, "categoryTag": NSDecimalNumber}}
// "expensesByMonthAndCategories", {idxMonth: {"self": IAEMonth, "categoryTag": NSDecimalNumber}}
// "conceptsByMonth", {idxMonth: {"self": IAEMonth, "concepts": @[concepts]}}
//

#import <Foundation/Foundation.h>

@interface IAEExporterConverter : NSObject

+ (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration;

@end
