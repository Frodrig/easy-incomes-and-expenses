//
//  IAEExporterConverter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporterConverter.h"
#import "IAEMonth.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEExporterDefs.h"

@implementation IAEExporterConverter

#pragma mark - Converter

+ (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    const BOOL globalsReport = [self isPresentWhatOption:kValueWhatOptionGlobalsReport inUserConfiguration:userConfiguration];
    const BOOL monthsReport = [self isPresentWhatOption:kValueWhatOptionMonthsReport inUserConfiguration:userConfiguration];
    const BOOL conceptsReport = [self isPresentWhatOption:kValueWhatOptionConceptsReport inUserConfiguration:userConfiguration];
    
    NSMutableDictionary *exportData = [NSMutableDictionary dictionary];
    
    [self exportSelectedMonthsFromUserConfiguration:userConfiguration toDestination:exportData];
    
    if (monthsReport) {
        [self exportMonthReportsFromUserConfiguration:userConfiguration toDestination:exportData];
    }
    
    if (globalsReport) {
        [self exportGlobalReportFromUserConfiguration:userConfiguration toDestination:exportData];
    }
    
    if (conceptsReport) {
        [self exportConceptsReportFromUserConfiguration:userConfiguration toDestination:exportData];
    }
    
    NSDictionary *resultExport = [NSDictionary dictionaryWithDictionary:exportData];
    return resultExport;
}

+ (void)exportSelectedMonthsFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)destination
{
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    destination[kKeyExportedDataSelectedMonths] = monthsSelected;
}

+ (void)exportMonthReportsFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)destination
{
    NSDictionary *totalsByMonth = [self convertTotalsByMonthToExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:totalsByMonth];
    
    NSDictionary *categoryTypesByMonth = [self convertCategoryTypesToAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:categoryTypesByMonth];
}

+ (void)exportGlobalReportFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)destination
{
    NSDictionary *totals = [self convertTotalsToExportDataFromUserConfiguration:userConfiguration];
    destination[kKeyExportedDataTotals] = totals;
    
    NSDictionary *incomesAndExpensesByCategories = [self convertCategoryTypesToAmountGlobalExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:incomesAndExpensesByCategories];
}

+ (void)exportConceptsReportFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)exportData
{
    NSDictionary *convertedData = [self convertConceptsToExportDataFromUserConfiguration:userConfiguration];
    exportData[kKeyExportedDataConceptsByMonth] = convertedData;
}

+ (BOOL)isPresentWhatOption:(NSString *)whatOption inUserConfiguration:(NSDictionary *)userConfiguration
{
    NSSet *whatOptions = userConfiguration[kKeyWhatOptions];
    const BOOL isPresent = [whatOptions containsObject:whatOption];
    
    return isPresent;
}

+ (NSDictionary *)convertTotalsToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDecimalNumber *balance = [NSDecimalNumber zero];
    NSDecimalNumber *incomes = [NSDecimalNumber zero];
    NSDecimalNumber *expenses = [NSDecimalNumber zero];
    
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        incomes = [incomes decimalNumberByAdding:[month incomes]];
        expenses = [expenses decimalNumberByAdding:[month expenses]];
    }
    
    balance = [incomes decimalNumberBySubtracting:expenses];
    
    NSDictionary *convertedData = @{kKeyExportedDataBalance: balance,
                                    kKeyExportedDataIncomes: incomes,
                                    kKeyExportedDataExpenses: expenses};
    return convertedData;
}

+ (NSDictionary *)convertCategoryTypesToAmountPerMonthExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDictionary *incomeCategories = [self convertCategoryType:IncomeCategory toAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    NSDictionary *expenseCategories = [self convertCategoryType:ExpenseCategory toAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    
    NSMutableDictionary *incomeAndExpenseCategories = [NSMutableDictionary dictionary];
    incomeAndExpenseCategories[kKeyExportedDataIncomeCategoriesByMonth] = incomeCategories;
    incomeAndExpenseCategories[kKeyExportedDataExpenseCategoriesByMonth] = expenseCategories;
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:incomeAndExpenseCategories];
    return resultDictionary;
}

+ (NSDictionary *)convertCategoryType:(CategoryType)categoryType toAmountPerMonthExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSAssert(categoryType != InvalidCategory, @"");
    
    NSMutableDictionary *convertedData = [NSMutableDictionary dictionary];
    
    NSArray *allCategoriesOfType = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryType];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        NSMutableDictionary *amountOfCategoriesInMonth = [NSMutableDictionary dictionary];
        amountOfCategoriesInMonth[kKeyExportedDataSelfMonth] = month;
        for (IAECategory *category in allCategoriesOfType) {
            NSDecimalNumber *balance = [month balanceOfAllConceptsOfCategory:category];
            if (![balance isEqualToNumber:[NSDecimalNumber zero]]) {
                amountOfCategoriesInMonth[[category localizedTag]] = balance;
            }
        }
        convertedData[@(month.month)] = [NSDictionary dictionaryWithDictionary:amountOfCategoriesInMonth];
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:convertedData];
    return resultConvertedData;
}

+ (NSDictionary *)convertTotalsByMonthToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSMutableDictionary *convertedData = [NSMutableDictionary dictionary];
    
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        NSDecimalNumber *balance = [month balance];
        NSDecimalNumber *incomes = [month incomes];
        NSDecimalNumber *expenses = [month expenses];
        
        convertedData[@(month.month)] = @{kKeyExportedDataSelfMonth: month,
                                          kKeyExportedDataBalance: balance,
                                          kKeyExportedDataIncomes: incomes,
                                          kKeyExportedDataExpenses: expenses};
    }
    
    NSDictionary *resultConvertedData = @{kKeyExportedDataTotalsByMonths: [NSDictionary dictionaryWithDictionary:convertedData]};
    return resultConvertedData;
}

+ (NSDictionary *)convertCategoryTypesToAmountGlobalExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDictionary *globalAmountOfIncomeCategories = [self convertCategoriesOfType:IncomeCategory toGlobalAmountWithUserConfiguration:userConfiguration];
    NSDictionary *globalAmountOfExpenseCategories = [self convertCategoriesOfType:ExpenseCategory toGlobalAmountWithUserConfiguration:userConfiguration];
    
    NSMutableDictionary *incomeAndExpenseCategories = [NSMutableDictionary dictionary];
    incomeAndExpenseCategories[kKeyExportedDataIncomeCategories] = globalAmountOfIncomeCategories;
    incomeAndExpenseCategories[kKeyExportedDataExpenseCategories] = globalAmountOfExpenseCategories;
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:incomeAndExpenseCategories];
    return resultDictionary;
}

+ (NSDictionary *)convertCategoriesOfType:(CategoryType)categoryType toGlobalAmountWithUserConfiguration:(NSDictionary *)userConfiguration
{
    NSAssert(categoryType != InvalidCategory, @"");
    
    NSMutableDictionary *amountOfCategories = [NSMutableDictionary dictionary];
    
    NSArray *allCategoriesOfType = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryType];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        for (IAECategory *category in allCategoriesOfType) {
            NSDecimalNumber *balance = [month balanceOfAllConceptsOfCategory:category];
            if (![balance isEqualToNumber:[NSDecimalNumber zero]]) {
                NSDecimalNumber *actualBalance = amountOfCategories[[category localizedTag]];
                if (actualBalance) {
                    amountOfCategories[[category localizedTag]] = [actualBalance decimalNumberByAdding:balance];
                } else {
                    amountOfCategories[[category localizedTag]] = balance;
                }
            }
        }
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:amountOfCategories];
    return resultConvertedData;
}

+ (NSDictionary *)convertConceptsToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSMutableDictionary *convertedData = [NSMutableDictionary dictionary];
    
    const BOOL isDayModeActive = [[NSUserDefaults standardUserDefaults] isDayModeActive];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        NSArray *concepts = isDayModeActive ? [month allConceptsSortedByDay] : [month allConceptsSortedByEntryInstant];
        NSDictionary *exportedConcepts = @{kKeyExportedDataSelfMonth: month,
                                           kKeyExportedDataConcepts: concepts};
        convertedData[@(month.month)] = exportedConcepts;
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:convertedData];
    return resultConvertedData;
}

@end
