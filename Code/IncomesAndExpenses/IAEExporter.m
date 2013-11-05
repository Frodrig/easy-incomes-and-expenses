//
//  IAEExporter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporter.h"
#import "IAEBook.h"
#import "IAEMonth.h"
#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "NSUserDefaults+EasyIncAndExp.h"

@implementation IAEExporter

#pragma mark - Constants

static NSString * const kKeyWhereCSV = @"where_csv";
static NSString * const kKeyWherePDF = @"where_pdf";
static NSString * const kKeyWherePrint = @"where_print";
static NSString * const kKeyWhatOptions = @"what_options";
static NSString * const kKeyMonthSelected = @"month_selected";

static NSString * const kValueWhatOptionGlobalsReport = @"globals_report";
static NSString * const kValueWhatOptionMonthsReport = @"moths_report";
static NSString * const kValueWhatOptionConceptsReport = @"concepts_report";

static NSString * const kKeyExportedDataTotals = @"totals";
static NSString * const kKeyExportedDataBalance = @"balance";
static NSString * const kKeyExportedDataIncomes = @"expenses";
static NSString * const kKeyExportedDataExpenses = @"incomes";
static NSString * const kKeyExportedDataIncomeCategories = @"incomesByCategory";
static NSString * const kKeyExportedDataExpenseCategories = @"expenseByCategory";
static NSString * const kKeyExportedDataIncomeCategoriesByMonth = @"incomesByMonthAndCategories";
static NSString * const kKeyExportedDataExpenseCategoriesByMonth = @"expensesByMonthAndCategories";
static NSString * const kKeyExportedDataConceptsByMonth = @"conceptsBytMonth";

#pragma mark - Class

+ (IAEExporter *)sharedExporter
{
    static dispatch_once_t once;
    static id sharedInstance;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Export

- (void)exportYearDate:(NSUInteger)yearDate withUserConfiguration:(NSDictionary *)userConfiguration
{
    NSAssert(userConfiguration, @"");
    NSAssert(userConfiguration[kKeyWherePrint] || userConfiguration[kKeyWherePDF] || userConfiguration[kKeyWhereCSV], @"");
    NSAssert(userConfiguration[kKeyMonthSelected], @"");
    NSAssert(userConfiguration[kKeyWhatOptions], @"");
    
    NSDictionary *convertedData = [self convertToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
    if ([userConfiguration[kKeyWhereCSV] boolValue]) {
        [self exportToCSVUsingMode:@"" inYearDate:yearDate withConvertedData:convertedData];
    }
    
    NSLog(@"%@", convertedData);
}

#pragma mark - Convert

// Formato:
//
// "totals". {"balance": NSDecimal, "expenses": NSDecimal, "incomes": NSDecimal}
// "incomesByCategory", {categoryTag: value}
// "expensesByCategory", {categoryTag: value}
// "incomesByMonthAndCategories", {idxMonth: {categoryTag: NSDecimalNumber}}
// "expensesByMonthAndCategories", {idxMonth: {categoryTag: NSDecimalNumber}}
// "conceptsByMonth", {idxMonth, [concepts]}
//
- (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    const BOOL globalsReport = [self isPresentWhatOption:kValueWhatOptionGlobalsReport inUserConfiguration:userConfiguration];
    const BOOL monthsReport = [self isPresentWhatOption:kValueWhatOptionMonthsReport inUserConfiguration:userConfiguration];
    const BOOL conceptsReport = [self isPresentWhatOption:kValueWhatOptionConceptsReport inUserConfiguration:userConfiguration];
    
    NSMutableDictionary *exportData = [NSMutableDictionary dictionary];
    
    if (monthsReport) {
        NSDictionary *convertedData = [self convertCategoryTypesToAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
        [exportData addEntriesFromDictionary:convertedData];
    }
    
    if (globalsReport) {
        NSDictionary *totals = [self convertTotalsToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataTotals] = totals;
        
        NSDictionary *incomesByCategory = [self convertCategoryTypesToAmountGlobalExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
        [exportData addEntriesFromDictionary:incomesByCategory];
    }
    
    if (conceptsReport) {
        NSDictionary *convertedData = [self convertConceptsToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataConceptsByMonth] = convertedData;
    }
    
    NSDictionary *resultExport = [NSDictionary dictionaryWithDictionary:exportData];
    return resultExport;
}

- (BOOL)isPresentWhatOption:(NSString *)whatOption inUserConfiguration:(NSDictionary *)userConfiguration
{
    NSSet *whatOptions = userConfiguration[kKeyWhatOptions];
    const BOOL isPresent = [whatOptions containsObject:whatOption];
    
    return isPresent;
}

- (NSDictionary *)convertTotalsToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
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

- (NSDictionary *)convertCategoryTypesToAmountPerMonthExportDataFromYear:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDictionary *incomeCategories = [self convertCategoryType:IncomeCategory toAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
    NSDictionary *expenseCategories = [self convertCategoryType:ExpenseCategory toAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
    
    NSMutableDictionary *incomeAndExpenseCategories = [NSMutableDictionary dictionary];
    incomeAndExpenseCategories[kKeyExportedDataIncomeCategoriesByMonth] = incomeCategories;
    incomeAndExpenseCategories[kKeyExportedDataExpenseCategoriesByMonth] = expenseCategories;
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:incomeAndExpenseCategories];
    return resultDictionary;
}

- (NSDictionary *)convertCategoryType:(CategoryType)categoryType toAmountPerMonthExportDataFromYear:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    NSAssert(categoryType != InvalidCategory, @"");

    NSMutableDictionary *convertedData = [NSMutableDictionary dictionary];
    
    NSArray *allCategoriesOfType = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryType];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        NSMutableDictionary *amountOfCategoriesInMonth = [NSMutableDictionary dictionary];
        for (IAECategory *category in allCategoriesOfType) {
            NSDecimalNumber *balance = [month balanceOfAllConceptsOfCategory:category];
            if (![balance isEqualToNumber:[NSDecimalNumber zero]]) {
                amountOfCategoriesInMonth[category.tag] = balance;
            }
        }
        
        convertedData[@(month.month)] = [NSDictionary dictionaryWithDictionary:amountOfCategoriesInMonth];
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:convertedData];
    return resultConvertedData;
}

- (NSDictionary *)convertCategoryTypesToAmountGlobalExportDataFromYear:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDictionary *globalAmountOfIncomeCategories = [self convertCategoriesOfType:IncomeCategory toGlobalAmountWithUserConfiguration:userConfiguration];
    NSDictionary *globalAmountOfExpenseCategories = [self convertCategoriesOfType:ExpenseCategory toGlobalAmountWithUserConfiguration:userConfiguration];
    
    NSMutableDictionary *incomeAndExpenseCategories = [NSMutableDictionary dictionary];
    incomeAndExpenseCategories[kKeyExportedDataIncomeCategories] = globalAmountOfIncomeCategories;
    incomeAndExpenseCategories[kKeyExportedDataExpenseCategories] = globalAmountOfExpenseCategories;
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:incomeAndExpenseCategories];
    return resultDictionary;
}

- (NSDictionary *)convertCategoriesOfType:(CategoryType)categoryType toGlobalAmountWithUserConfiguration:(NSDictionary *)userConfiguration
{
    NSAssert(categoryType != InvalidCategory, @"");
    
    NSMutableDictionary *amountOfCategories = [NSMutableDictionary dictionary];
    
    NSArray *allCategoriesOfType = [[IAECategoryStore sharedCategoryStore] generalCategoryAndAllUserCategoriesOfType:categoryType];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        for (IAECategory *category in allCategoriesOfType) {
            NSDecimalNumber *balance = [month balanceOfAllConceptsOfCategory:category];
            if (![balance isEqualToNumber:[NSDecimalNumber zero]]) {
                NSDecimalNumber *actualBalance = amountOfCategories[category.tag];
                if (actualBalance) {
                    amountOfCategories[category.tag] = [actualBalance decimalNumberByAdding:balance];
                } else {
                    amountOfCategories[category.tag] = balance;
                }
            }
        }
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:amountOfCategories];
    return resultConvertedData;
}

- (NSDictionary *)convertConceptsToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    NSMutableDictionary *convertedData = [NSMutableDictionary dictionary];

    const BOOL isDayModeActive = [[NSUserDefaults standardUserDefaults] isDayModeActive];
    NSArray *monthsSelected = userConfiguration[kKeyMonthSelected];
    for (IAEMonth *month in monthsSelected) {
        convertedData[@(month.month)] = isDayModeActive ? [month allConceptsSortedByDay] : [month allConceptsSortedByEntryInstant];
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:convertedData];
    return resultConvertedData;
}

#pragma mark - Export

- (void)exportToCSVUsingMode:(NSString *)keyMode inYearDate:(NSUInteger)yearDate withConvertedData:(NSDictionary *)convertedData
{
}

@end
