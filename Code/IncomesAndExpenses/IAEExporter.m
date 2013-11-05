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
#import "IAENumberFormatterManager.h"

@implementation IAEExporter

#pragma mark - Constants

static NSString * const kKeyWhereCSV = @"where_csv";
static NSString * const kKeyWherePDF = @"where_pdf";
static NSString * const kKeyWherePrint = @"where_print";
static NSString * const kKeyWhatOptions = @"what_options";
static NSString * const kKeyMonthSelected = @"month_selected";

static NSString * const kValueWhatOptionGlobalsReport = @"globals_report";
static NSString * const kValueWhatOptionMonthsReport = @"months_report";
static NSString * const kValueWhatOptionConceptsReport = @"concepts_report";

static NSString * const kKeyExportedDataTotals = @"totals";
static NSString * const kKeyExportedDataBalance = @"balance";
static NSString * const kKeyExportedDataIncomes = @"expenses";
static NSString * const kKeyExportedDataExpenses = @"incomes";
static NSString * const kKeyExportedDataSelfMonth = @"self";
static NSString * const kKeyExportedDataIncomeCategories = @"incomesByCategory";
static NSString * const kKeyExportedDataExpenseCategories = @"expenseByCategory";
static NSString * const kKeyExportedDataTotalsByMonths = @"totalsByMonth";
static NSString * const kKeyExportedDataIncomeCategoriesByMonth = @"incomesByMonthAndCategories";
static NSString * const kKeyExportedDataExpenseCategoriesByMonth = @"expensesByMonthAndCategories";
static NSString * const kKeyExportedDataConceptsByMonth = @"conceptsBytMonth";
static NSString * const kKeyExportedDataConcepts = @"concepts";

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
    
    NSSet *modes = userConfiguration[kKeyWhatOptions];
    NSDictionary *convertedData = [self convertToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
    if ([userConfiguration[kKeyWhereCSV] boolValue]) {
        [self exportToCSVUsingModes:modes inYearDate:yearDate withConvertedUserConfiguration:convertedData];
    }
    
    NSLog(@"%@", convertedData);
}

#pragma mark - Convert

// Formato:
//
// "totals". {"balance": NSDecimal, "expenses": NSDecimal, "incomes": NSDecimal}
// "incomesByCategory", {categoryTag: value}
// "expensesByCategory", {categoryTag: value}
// "totalsByMonth", {idxMonth: {"self": IAEMonth, "balance": NSDecimalNumber, "expenses": NSDecimalNumber, "incomes": NSDecimalNumber}}
// "incomesByMonthAndCategories", {idxMonth: {"self": IAEMonth, "categoryTag": NSDecimalNumber}}
// "expensesByMonthAndCategories", {idxMonth: {"self": IAEMonth, "categoryTag": NSDecimalNumber}}
// "conceptsByMonth", {idxMonth, {"self": IAEMonth, "concepts": @[concepts]}}
//
- (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    const BOOL globalsReport = [self isPresentWhatOption:kValueWhatOptionGlobalsReport inUserConfiguration:userConfiguration];
    const BOOL monthsReport = [self isPresentWhatOption:kValueWhatOptionMonthsReport inUserConfiguration:userConfiguration];
    const BOOL conceptsReport = [self isPresentWhatOption:kValueWhatOptionConceptsReport inUserConfiguration:userConfiguration];
    
    NSMutableDictionary *exportData = [NSMutableDictionary dictionary];
    
    if (monthsReport) {
        NSDictionary *totalsByMonth = [self convertTotalsByMonthToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
        [exportData addEntriesFromDictionary:totalsByMonth];
        
        NSDictionary *categoryTypesByMonth = [self convertCategoryTypesToAmountPerMonthExportDataFromYear:yearDate andUserConfiguration:userConfiguration];
        [exportData addEntriesFromDictionary:categoryTypesByMonth];
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
        amountOfCategoriesInMonth[kKeyExportedDataSelfMonth] = month;
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

- (NSDictionary *)convertTotalsByMonthToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
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
        NSArray *concepts = isDayModeActive ? [month allConceptsSortedByDay] : [month allConceptsSortedByEntryInstant];
        NSDictionary *exportedConcepts = @{kKeyExportedDataSelfMonth: month,
                                           kKeyExportedDataConcepts: concepts};
        convertedData[@(month.month)] = exportedConcepts;
    }
    
    NSDictionary *resultConvertedData = [NSDictionary dictionaryWithDictionary:convertedData];
    return resultConvertedData;
}

#pragma mark - Export

- (void)exportToCSVUsingModes:(NSSet *)modes inYearDate:(NSUInteger)yearDate withConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSAssert(modes.count > 0, @"");
    
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:@"export_csv.csv"];
    const BOOL fileManagerOk = [[NSFileManager defaultManager] createFileAtPath:pathForTMPDirectory contents:nil attributes:nil];
    if (fileManagerOk) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathForTMPDirectory];
        const BOOL fileHandleOk = fileHandle != nil;
        if (fileHandleOk) {
            [fileHandle seekToEndOfFile];
            
            NSData *headerData = [self generateDataToExportCSVHeaderWithYear:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
            [fileHandle writeData:headerData];
            
            const BOOL exportGlobalsReport = [modes containsObject:kValueWhatOptionGlobalsReport];
            if (exportGlobalsReport) {
                NSData *globalReport = [self generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:convertedUserConfiguration];
                [fileHandle writeData:globalReport];
            }
            
            const BOOL exportMonthReport = [modes containsObject:kValueWhatOptionMonthsReport];
            if (exportMonthReport) {
                NSData *monthReport = [self generateDatatoExportCSVMonthReportWithConvertedUserConfiguration:convertedUserConfiguration];
                [fileHandle writeData:monthReport];
            }
            
            const BOOL exportConceptsReport = [modes containsObject:kValueWhatOptionConceptsReport];
            if (exportConceptsReport) {
                
            }
            
            [fileHandle closeFile];
        }
    }
}

- (NSData *)generateDataToExportCSVHeaderWithYear:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSString *dataStr = [NSString stringWithFormat:NSLocalizedString(@"LTEXT_EXPORTCSV_HEADER", ""), yearDate];
    dataStr = [dataStr stringByAppendingString:@"\n\n"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSData *)generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"%@\n\n", NSLocalizedString(@"LTEXT_EXPORTCSV_GLOBALREPORT_HEADER", @"")];
    
    NSDictionary *totals = convertedUserConfiguration[kKeyExportedDataTotals];
    [dataStr appendString:[self generateStringDataToExportCSVTotalsFromSource:totals]];
    
    NSDictionary *incomeCategories = convertedUserConfiguration[kKeyExportedDataIncomeCategories];
    [dataStr appendString:@"\n"];
    [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:incomeCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_EXPENSECATEGORIES", @"")]];
    
    NSDictionary *expenseCategories = convertedUserConfiguration[kKeyExportedDataExpenseCategories];
    [dataStr appendString:@"\n"];
    [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:expenseCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_INCOMECATEGORIES", @"")]];
    
    [dataStr appendString:@"\n"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSData *)generateDatatoExportCSVMonthReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    __block NSMutableArray *monthsTotals = [NSMutableArray array];
    NSDictionary *totalsByMonths = convertedUserConfiguration[kKeyExportedDataTotalsByMonths];
    [totalsByMonths enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [monthsTotals addObject:obj];
    }];
    
    __block NSMutableArray *monthsIncomeCategories = [NSMutableArray array];
    NSDictionary *incomeCategoriesByMonths = convertedUserConfiguration[kKeyExportedDataIncomeCategoriesByMonth];
    [incomeCategoriesByMonths enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [monthsIncomeCategories addObject:obj];
    }];
    
    __block NSMutableArray *monthsExpenseCategories = [NSMutableArray array];
    NSDictionary *expenseCategoriesByMonths = convertedUserConfiguration[kKeyExportedDataExpenseCategoriesByMonth];
    [expenseCategoriesByMonths enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [monthsExpenseCategories addObject:obj];
    }];
    
    NSAssert(monthsTotals.count == monthsIncomeCategories.count &&  monthsIncomeCategories.count == monthsExpenseCategories.count, @"");
    
    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"%@\n\n", NSLocalizedString(@"LTEXT_EXPORTCSV_MONTHREPORT_HEADER", @"")];
    
    const NSUInteger maxMonths = monthsTotals.count;
    for (NSUInteger monthsIdx = 0; monthsIdx < maxMonths; ++monthsIdx) {
        NSDictionary *totals = monthsTotals[monthsIdx];
        NSMutableDictionary *incomeCategories = [NSMutableDictionary dictionaryWithDictionary:monthsIncomeCategories[monthsIdx]];
        NSMutableDictionary *expenseCategories = [NSMutableDictionary dictionaryWithDictionary:monthsExpenseCategories[monthsIdx]];
        
        IAEMonth *month = totals[kKeyExportedDataSelfMonth];
        
        [dataStr appendString:[NSString stringWithFormat:@"%@\n", [month monthAsString]]];
        [dataStr appendString:[self generateStringDataToExportCSVTotalsFromSource:totals]];
        
        [incomeCategories removeObjectForKey:kKeyExportedDataSelfMonth];
        [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:incomeCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_INCOMECATEGORIES", @"")]];
        
        [expenseCategories removeObjectForKey:kKeyExportedDataSelfMonth];
        [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:expenseCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_EXPENSECATEGORIES", @"")]];
    }
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF8StringEncoding];
    return data;
}

- (NSString *)generateStringDataToExportCSVTotalsFromSource:(NSDictionary *)source
{
    NSNumberFormatter *formatter = [IAENumberFormatterManager sharedManager].currencyFormatter;

    NSMutableString *dataStr = [NSMutableString string];

    NSString *balance = [formatter stringFromNumber:source[kKeyExportedDataBalance]];
    NSString *incomes = [formatter stringFromNumber:source[kKeyExportedDataIncomes]];
    NSString *expenses = [formatter stringFromNumber:[source[kKeyExportedDataExpenses] decimalNumberByMultiplyingBy:[NSDecimalNumber decimalNumberWithString:@"-1"]]];
    [dataStr appendString:[NSString stringWithFormat:@"%@\n", NSLocalizedString(@"LTEXT_EXPORTCSV_TOTALS_SECTION_HEADER", @"")]];
    [dataStr appendString:[NSString stringWithFormat:@"%@,\"%@\"\n", NSLocalizedString(@"LTEXT_EXPORTCSV_TOTALS_BALANCE", @""), balance]];
    [dataStr appendString:[NSString stringWithFormat:@"%@,\"%@\"\n", NSLocalizedString(@"LTEXT_EXPORTCSV_TOTALS_INCOMES", @""), incomes]];
    [dataStr appendString:[NSString stringWithFormat:@"%@,\"%@\"\n", NSLocalizedString(@"LTEXT_EXPORTCSV_TOTALS_EXPENSES", @""), expenses]];
    
    return dataStr;
}

- (NSString *)generateStringDataToExportCSVCategoriesFromSource:(NSDictionary *)source withHeader:(NSString *)header
{
    NSNumberFormatter *formatter = [IAENumberFormatterManager sharedManager].currencyFormatter;
    
    __block NSMutableString *dataStr = [NSMutableString string];

    [dataStr appendString:[NSString stringWithFormat:@"\"%@\"\n", header]];
    [source enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSString *categoryAmount = [formatter stringFromNumber:obj];
        [dataStr appendString:[NSString stringWithFormat:@"%@,\"%@\"\n", key, categoryAmount]];
    }];
    
    return dataStr;
}

@end
