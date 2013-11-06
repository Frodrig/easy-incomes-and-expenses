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
#import "IAEConcept.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAENumberFormatterManager.h"

@implementation IAEExporter

#pragma mark - Constants

static NSString * const kExportCSVFileNameWithExtension = @"export.csv";

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
    
    NSDictionary *convertedData = [self convertToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
    
    NSSet *modes = userConfiguration[kKeyWhatOptions];
    
    const BOOL exportToCSV = [userConfiguration[kKeyWhereCSV] boolValue];
    if (exportToCSV) {
        [self exportToCSVUsingModes:modes inYearDate:yearDate withConvertedUserConfiguration:convertedData];
    }
    
    const BOOL exportToPDF = [userConfiguration[kKeyWherePDF] boolValue];
    if (exportToPDF) {
        
    }
    
    const BOOL exportToPrint = [userConfiguration[kKeyWherePrint] boolValue];
    if (exportToPrint) {
        
    }
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
// "conceptsByMonth", {idxMonth: {"self": IAEMonth, "concepts": @[concepts]}}
//
- (NSDictionary *)convertToExportDataFromYearDate:(NSUInteger)yearDate andUserConfiguration:(NSDictionary *)userConfiguration
{
    const BOOL globalsReport = [self isPresentWhatOption:kValueWhatOptionGlobalsReport inUserConfiguration:userConfiguration];
    const BOOL monthsReport = [self isPresentWhatOption:kValueWhatOptionMonthsReport inUserConfiguration:userConfiguration];
    const BOOL conceptsReport = [self isPresentWhatOption:kValueWhatOptionConceptsReport inUserConfiguration:userConfiguration];
    
    NSMutableDictionary *exportData = [NSMutableDictionary dictionary];
    
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

- (void)exportMonthReportsFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)destination
{
    NSDictionary *totalsByMonth = [self convertTotalsByMonthToExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:totalsByMonth];
    
    NSDictionary *categoryTypesByMonth = [self convertCategoryTypesToAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:categoryTypesByMonth];
}

- (void)exportGlobalReportFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)destination
{
    NSDictionary *totals = [self convertTotalsToExportDataFromUserConfiguration:userConfiguration];
    destination[kKeyExportedDataTotals] = totals;
    
    NSDictionary *incomesAndExpensesByCategories = [self convertCategoryTypesToAmountGlobalExportDataFromUserConfiguration:userConfiguration];
    [destination addEntriesFromDictionary:incomesAndExpensesByCategories];
}

- (void)exportConceptsReportFromUserConfiguration:(NSDictionary *)userConfiguration toDestination:(NSMutableDictionary *)exportData
{
    NSDictionary *convertedData = [self convertConceptsToExportDataFromUserConfiguration:userConfiguration];
    exportData[kKeyExportedDataConceptsByMonth] = convertedData;
}

- (BOOL)isPresentWhatOption:(NSString *)whatOption inUserConfiguration:(NSDictionary *)userConfiguration
{
    NSSet *whatOptions = userConfiguration[kKeyWhatOptions];
    const BOOL isPresent = [whatOptions containsObject:whatOption];
    
    return isPresent;
}

- (NSDictionary *)convertTotalsToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
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

- (NSDictionary *)convertCategoryTypesToAmountPerMonthExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
{
    NSDictionary *incomeCategories = [self convertCategoryType:IncomeCategory toAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    NSDictionary *expenseCategories = [self convertCategoryType:ExpenseCategory toAmountPerMonthExportDataFromUserConfiguration:userConfiguration];
    
    NSMutableDictionary *incomeAndExpenseCategories = [NSMutableDictionary dictionary];
    incomeAndExpenseCategories[kKeyExportedDataIncomeCategoriesByMonth] = incomeCategories;
    incomeAndExpenseCategories[kKeyExportedDataExpenseCategoriesByMonth] = expenseCategories;
    
    NSDictionary *resultDictionary = [NSDictionary dictionaryWithDictionary:incomeAndExpenseCategories];
    return resultDictionary;
}

- (NSDictionary *)convertCategoryType:(CategoryType)categoryType toAmountPerMonthExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
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

- (NSDictionary *)convertTotalsByMonthToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
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

- (NSDictionary *)convertCategoryTypesToAmountGlobalExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
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

- (NSDictionary *)convertConceptsToExportDataFromUserConfiguration:(NSDictionary *)userConfiguration
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
    
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:kExportCSVFileNameWithExtension];
    const BOOL fileManagerOk = [[NSFileManager defaultManager] createFileAtPath:pathForTMPDirectory contents:nil attributes:nil];
    if (fileManagerOk) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathForTMPDirectory];
        const BOOL fileHandleOk = fileHandle != nil;
        if (fileHandleOk) {
            [fileHandle seekToEndOfFile];
            [self writeCSVToFile:fileHandle withModes:modes yearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
            [fileHandle closeFile];
        } else {
            // Fallo creando el FileHandle
        }
    } else {
        // Fallo creando el FileManager
    }
}

- (void)writeCSVToFile:(NSFileHandle *)fileHandle withModes:(NSSet *)modes yearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    [self writeCSVHeaderToFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVGlobalReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVMonthsReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVConceptsReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
}

- (void)writeCSVHeaderToFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSData *headerData = [self generateDataToExportCSVHeaderWithYear:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [fileHandle writeData:headerData];
}

- (void)writeCSVGlobalReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportGlobalsReport = [modes containsObject:kValueWhatOptionGlobalsReport];
    if (exportGlobalsReport) {
        NSData *globalReport = [self generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:globalReport];
    }
}

- (void)writeCSVMonthsReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportMonthReport = [modes containsObject:kValueWhatOptionMonthsReport];
    if (exportMonthReport) {
        NSData *monthReport = [self generateDataToExportCSVMonthReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:monthReport];
    }
}

- (void)writeCSVConceptsReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportConceptsReport = [modes containsObject:kValueWhatOptionConceptsReport];
    if (exportConceptsReport) {
        NSData *conceptReport = [self generateDataToExportCSVConceptReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:conceptReport];
    }
}

- (NSData *)generateDataToExportCSVHeaderWithYear:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSString *dataStr = [NSString stringWithFormat:NSLocalizedString(@"LTEXT_EXPORTCSV_HEADER", ""), yearDate];
    dataStr = [dataStr stringByAppendingString:@"\n\n"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
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
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
    return data;
}

- (NSData *)generateDataToExportCSVMonthReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    __block NSArray *monthsTotals = [self extractOrdererMonthsWithTotalsFromConvertedUserConfiguration:convertedUserConfiguration];
    __block NSArray *monthsIncomeCategories = [self extractOrdererMonthsIncomeCategoriesFromConvertedUserConfiguration:convertedUserConfiguration];
    __block NSArray *monthsExpenseCategories = [self extractOrdererMonthsExpenseCategoriesFromConvertedUserConfiguration:convertedUserConfiguration];
    NSAssert(monthsTotals.count == monthsIncomeCategories.count &&  monthsIncomeCategories.count == monthsExpenseCategories.count, @"");
    
    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"%@\n", NSLocalizedString(@"LTEXT_EXPORTCSV_MONTHREPORT_HEADER", @"")];
    
    const NSUInteger maxMonths = monthsTotals.count;
    for (NSUInteger monthsIdx = 0; monthsIdx < maxMonths; ++monthsIdx) {
        NSDictionary *totals = monthsTotals[monthsIdx];
        NSMutableDictionary *incomeCategories = [NSMutableDictionary dictionaryWithDictionary:monthsIncomeCategories[monthsIdx]];
        NSMutableDictionary *expenseCategories = [NSMutableDictionary dictionaryWithDictionary:monthsExpenseCategories[monthsIdx]];
        
        IAEMonth *month = totals[kKeyExportedDataSelfMonth];
        
        [dataStr appendString:[NSString stringWithFormat:@"\n%@\n\n", [month monthAsString]]];
        [dataStr appendString:[self generateStringDataToExportCSVTotalsFromSource:totals]];
        
        [dataStr appendString:@"\n"];
        [incomeCategories removeObjectForKey:kKeyExportedDataSelfMonth];
        [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:incomeCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_INCOMECATEGORIES", @"")]];

        [dataStr appendString:@"\n"];
        [expenseCategories removeObjectForKey:kKeyExportedDataSelfMonth];
        [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:expenseCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_EXPENSECATEGORIES", @"")]];
    }
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
    return data;
}

- (NSArray *)extractOrdererMonthsWithTotalsFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthsTotals = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                    associatedToDataKey:kKeyExportedDataTotalsByMonths];
    return retMonthsTotals;
}

- (NSArray *)extractOrdererMonthsIncomeCategoriesFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthIncomeCategories = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                             associatedToDataKey:kKeyExportedDataIncomeCategoriesByMonth];
    return retMonthIncomeCategories;
}

- (NSArray *)extractOrdererMonthsExpenseCategoriesFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthExpenseCategories = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                              associatedToDataKey:kKeyExportedDataExpenseCategoriesByMonth];
    return retMonthExpenseCategories;
}

- (NSArray *)extractOrdererMonthsFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration associatedToDataKey:(NSString *)dataKey
{
    __block NSMutableArray *foundMonths = [NSMutableArray array];
    NSDictionary *dataAssociatedWithKey = convertedUserConfiguration[dataKey];
    [dataAssociatedWithKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [foundMonths addObject:obj];
    }];
    
    NSArray *retMonths = [NSArray arrayWithArray:foundMonths];
    return retMonths;
}

- (NSData *)generateDataToExportCSVConceptReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSNumberFormatter *formatter = [IAENumberFormatterManager sharedManager].currencyFormatter;

    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"\n%@\n", NSLocalizedString(@"LTEXT_EXPORTCSV_CONCEPTREPORT_HEADER", @"")];

    const BOOL dayModeActive = [[NSUserDefaults standardUserDefaults] isDayModeActive];
    
    NSDictionary *conceptsOfMonths = convertedUserConfiguration[kKeyExportedDataConceptsByMonth];
    
    [conceptsOfMonths enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSDictionary *monthData = obj;
        IAEMonth *month = monthData[kKeyExportedDataSelfMonth];
        NSArray *concepts = monthData[kKeyExportedDataConcepts];
        [dataStr appendString:[NSString stringWithFormat:@"\n%@\n\n", [month monthAsString]]];
        NSUInteger idxConcept = 1;
        for (IAEConcept *concept in concepts) {
            NSString *indicator = nil;
            if (dayModeActive) {
                indicator = concept.dayOfTheMonth != 0 ? [NSString stringWithFormat:NSLocalizedString(@"LTEXT_EXPORTCSV_CONCEPTREPORT_DAY", ""), concept.dayOfTheMonth] :
                                                         [NSString stringWithFormat:NSLocalizedString(@"LTEXT_EXPORTCSV_CONCEPTREPORT_NODAY", "")];
            } else {
                indicator = [NSString stringWithFormat:@"%d", idxConcept];
            }
            [dataStr appendString:[NSString stringWithFormat:@"\"%@\",\"%@\",\"%@\"\n", indicator, [concept.category localizedTag], [formatter stringFromNumber:[concept amountWithSign]]]];
            ++idxConcept;
        }
    }];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
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
