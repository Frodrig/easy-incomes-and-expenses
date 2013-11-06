//
//  IAEExporterWritter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporterWritter.h"
#import "IAEDateHelper.h"
#import "IAEMonth.h"
#import "IAECategory.h"
#import "IAEConcept.h"
#import "IAENumberFormatterManager.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import "IAEExporterDefs.h"

@implementation IAEExporterWritter

#pragma mark - Constants


#pragma mark - Export

+ (void)exportToCSVUsingModes:(NSSet *)modes inYearDate:(NSUInteger)yearDate withConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
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

+ (void)writeCSVToFile:(NSFileHandle *)fileHandle withModes:(NSSet *)modes yearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    [self writeCSVHeaderToFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVGlobalReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVMonthsReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [self writeCSVConceptsReportIfModePresentInModes:modes toFile:fileHandle withYearDate:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
}

+ (void)writeCSVHeaderToFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSData *headerData = [self generateDataToExportCSVHeaderWithYear:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    [fileHandle writeData:headerData];
}

+ (void)writeCSVGlobalReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportGlobalsReport = [modes containsObject:kValueWhatOptionGlobalsReport];
    if (exportGlobalsReport) {
        NSData *globalReport = [self generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:globalReport];
    }
}

+ (void)writeCSVMonthsReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportMonthReport = [modes containsObject:kValueWhatOptionMonthsReport];
    if (exportMonthReport) {
        NSData *monthReport = [self generateDataToExportCSVMonthReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:monthReport];
    }
}

+ (void)writeCSVConceptsReportIfModePresentInModes:(NSSet *)modes toFile:(NSFileHandle *)fileHandle withYearDate:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    const BOOL exportConceptsReport = [modes containsObject:kValueWhatOptionConceptsReport];
    if (exportConceptsReport) {
        NSData *conceptReport = [self generateDataToExportCSVConceptReportWithConvertedUserConfiguration:convertedUserConfiguration];
        [fileHandle writeData:conceptReport];
    }
}

+ (NSData *)generateDataToExportCSVHeaderWithYear:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSMutableString *dataStr = [NSMutableString stringWithFormat:NSLocalizedString(@"LTEXT_EXPORTCSV_HEADER", ""), [IAEDateHelper createYearIdentificationTagFromYearDate:yearDate withShortForm:NO]];
    [dataStr appendString:@"\n"];
    
    const NSUInteger kNumberOfMonthsPerYear = 12;
    
    NSArray *selectedMonths = convertedUserConfiguration[kKeyExportedDataSelectedMonths];
    if (selectedMonths.count < kNumberOfMonthsPerYear) {
        [dataStr appendString:NSLocalizedString(@"LTEXT_EXPORTCSV_HEADER_MONTHS", @"")];
        for (IAEMonth *month in selectedMonths) {
            const BOOL lastMonth = [selectedMonths indexOfObject:month] == selectedMonths.count - 1;
            NSString *stringFormat = lastMonth ? @"%@" : @"\"%@, \"";
            [dataStr appendString:[NSString stringWithFormat:stringFormat, [[month monthAsString] lowercaseString]]];
        }
    } else {
        [dataStr appendString:NSLocalizedString(@"LTEXT_EXPORTCSV_HEADER_ALLMONTHS", @"")];
    }
    
    [dataStr appendString:@"\n\n"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
    return data;
}

+ (NSData *)generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"%@\n\n", NSLocalizedString(@"LTEXT_EXPORTCSV_GLOBALREPORT_HEADER", @"")];
    
    NSDictionary *totals = convertedUserConfiguration[kKeyExportedDataTotals];
    [dataStr appendString:[self generateStringDataToExportCSVTotalsFromSource:totals]];
    
    NSDictionary *incomeCategories = convertedUserConfiguration[kKeyExportedDataIncomeCategories];
    [dataStr appendString:@"\n"];
    [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:incomeCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_INCOMESCATEGORIES", @"")]];
    
    NSDictionary *expenseCategories = convertedUserConfiguration[kKeyExportedDataExpenseCategories];
    [dataStr appendString:@"\n"];
    [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:expenseCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_EXPENSECATEGORIES", @"")]];
    
    [dataStr appendString:@"\n"];
    
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
    return data;
}

+ (NSData *)generateDataToExportCSVMonthReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
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

+ (NSArray *)extractOrdererMonthsWithTotalsFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthsTotals = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                    associatedToDataKey:kKeyExportedDataTotalsByMonths];
    return retMonthsTotals;
}

+ (NSArray *)extractOrdererMonthsIncomeCategoriesFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthIncomeCategories = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                             associatedToDataKey:kKeyExportedDataIncomeCategoriesByMonth];
    return retMonthIncomeCategories;
}

+ (NSArray *)extractOrdererMonthsExpenseCategoriesFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    NSArray *retMonthExpenseCategories = [self extractOrdererMonthsFromConvertedUserConfiguration:convertedUserConfiguration
                                                                              associatedToDataKey:kKeyExportedDataExpenseCategoriesByMonth];
    return retMonthExpenseCategories;
}

+ (NSArray *)extractOrdererMonthsFromConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration associatedToDataKey:(NSString *)dataKey
{
    __block NSMutableArray *foundMonths = [NSMutableArray array];
    NSDictionary *dataAssociatedWithKey = convertedUserConfiguration[dataKey];
    [dataAssociatedWithKey enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [foundMonths addObject:obj];
    }];
    
    [foundMonths sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAEMonth *month1 = [obj1 objectForKey:kKeyExportedDataSelfMonth];
        IAEMonth *month2 = [obj2 objectForKey:kKeyExportedDataSelfMonth];
        NSComparisonResult result = [month1 compare:month2];
        
        return result;
    }];
    
    NSArray *retMonths = [NSArray arrayWithArray:foundMonths];
    return retMonths;
}

+ (NSData *)generateDataToExportCSVConceptReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
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

+ (NSString *)generateStringDataToExportCSVTotalsFromSource:(NSDictionary *)source
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

+ (NSString *)generateStringDataToExportCSVCategoriesFromSource:(NSDictionary *)source withHeader:(NSString *)header
{
    NSNumberFormatter *formatter = [IAENumberFormatterManager sharedManager].currencyFormatter;
    
    __block NSMutableString *dataStr = [NSMutableString string];
    
    [dataStr appendString:[NSString stringWithFormat:@"\"%@\"\n", header]];
    NSArray *keysSortedByValue = [source keysSortedByValueUsingSelector:@selector(compare:)];
    
    for (NSString *key in keysSortedByValue.reverseObjectEnumerator) {
        NSDecimalNumber *value = source[key];
        NSString *categoryAmount = [formatter stringFromNumber:value];
        [dataStr appendString:[NSString stringWithFormat:@"%@,\"%@\"\n", key, categoryAmount]];
    }
    
    return dataStr;
}

@end
