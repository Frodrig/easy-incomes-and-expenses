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
static NSString * const kKeyHowOption = @"how_option";
static NSString * const kKeyWhatOptions = @"what_options";
static NSString * const kKeyMonthSelected = @"month_selected";

static NSString * const kValueHowOptionGlobalResume = @"globalResume";
static NSString * const kValueHowOptionMonthByMonth = @"monthByMonth";
static NSString * const kValueHowOptionMonthByMonthAndGlobalResume = @"globalResumeAndMonthByMonth";
static NSString * const kValueWhatOptionTotals = @"totals";
static NSString * const kValueWhatOptionCategoryIncomes = @"categoryIncomes";
static NSString * const kValueWhatOptionCategoryExpenses = @"categoryExpenses";
static NSString * const kValueWhatOptionConcepts = @"concepts";

static NSString * const kKeyExportedDataTotals = @"Totals";
static NSString * const kKeyExportedDataBalance = @"balance";
static NSString * const kKeyExportedDataIncomes = @"expenses";
static NSString * const kKeyExportedDataExpenses = @"incomes";
static NSString * const kKeyExportedDataCategoryIncomes = @"incomesByMonthAndCategories";
static NSString * const kKeyExportedDataCategoryExpenses = @"expensesByMonthAndCategories";
static NSString * const kKeyExportedDataConcepts = @"conceptsBytMonth";

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
    NSAssert(userConfiguration[kKeyHowOption], @"");
    NSAssert(userConfiguration[kKeyMonthSelected], @"");
    NSAssert(userConfiguration[kKeyWhatOptions], @"");
    
    NSString *mode = userConfiguration[kKeyHowOption];
    NSDictionary *convertedData = [self convertToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
    if ([userConfiguration[kKeyWhereCSV] boolValue]) {
        [self exportToCSVUsingMode:mode inYearDate:yearDate withConvertedData:convertedData];
    }
    
    NSLog(@"%@", convertedData);
}

#pragma mark - Convert

// Formato:
//
// "balance", NSDecimalNumber
// "expenses", NSDecimalNumber
// "incomes", NSDecimalNumber
// "incomesByMonthAndCategories", {idxMonth, {categoryTag, NSDecimalNumber} }
// "expensesByMonthAndCategories", {idxMonth, {categoryTag, NSDecimalNumber} }
// "conceptsByMonth", {idxMonth, [concepts] }
//
- (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    NSMutableDictionary *exportData = [NSMutableDictionary dictionary];
    
    if ([self isPresentWhatOption:kValueWhatOptionTotals inUserConfiguration:userConfiguration]) {
        NSDictionary *convertedData = [self convertTotalsToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataTotals] = convertedData;
    }
    
    if ([self isPresentWhatOption:kValueWhatOptionCategoryIncomes inUserConfiguration:userConfiguration]) {
        NSDictionary *convertedData = [self convertCategoryType:IncomeCategory toAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataCategoryIncomes] = convertedData;
    }
    
    if ([self isPresentWhatOption:kValueWhatOptionCategoryExpenses inUserConfiguration:userConfiguration]) {
        NSDictionary *convertedData = [self convertCategoryType:ExpenseCategory toAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataCategoryExpenses] = convertedData;
    }
    
    if ([self isPresentWhatOption:kValueWhatOptionConcepts inUserConfiguration:userConfiguration]) {
        NSDictionary *convertedData = [self convertConceptsToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
        exportData[kKeyExportedDataConcepts] = convertedData;
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
    if ([keyMode isEqualToString:kValueHowOptionGlobalResume]) {
        
    } else if ([keyMode isEqualToString:kValueHowOptionMonthByMonth]) {
        
    } else if ([keyMode isEqualToString:kValueHowOptionMonthByMonthAndGlobalResume]) {
        
    }
}


@end
