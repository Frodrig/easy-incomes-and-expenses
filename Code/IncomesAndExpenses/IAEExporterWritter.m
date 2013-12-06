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


#pragma mark - Export CSV

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
            // TODO: Fallo creando el FileHandle
        }
    } else {
        // TODO: Fallo creando el FileManager
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
    NSString *dataStr = [self generateStringToExportHeaderWithYear:yearDate andConvertedUserConfiguration:convertedUserConfiguration];
    NSData *data = [dataStr dataUsingEncoding:NSUTF16StringEncoding];
    
    return data;
}

+ (NSString *)generateStringToExportHeaderWithYear:(NSUInteger)yearDate andConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
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
    
    return dataStr;
}

+ (NSData *)generateDataToExportCSVGlobalReportWithConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    __block NSMutableString *dataStr = [NSMutableString stringWithFormat:@"%@\n\n", NSLocalizedString(@"LTEXT_EXPORTCSV_GLOBALREPORT_HEADER", @"")];
    
    NSDictionary *totals = convertedUserConfiguration[kKeyExportedDataTotals];
    [dataStr appendString:[self generateStringDataToExportCSVTotalsFromSource:totals]];
    
    NSDictionary *incomeCategories = convertedUserConfiguration[kKeyExportedDataIncomeCategories];
    [dataStr appendString:@"\n"];
    [dataStr appendString:[self generateStringDataToExportCSVCategoriesFromSource:incomeCategories withHeader:NSLocalizedString(@"LTEXT_EXPORTCSV_INCOMECATEGORIES", @"")]];
    
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

#pragma mark - Export PDF

+ (void)exportToPDFUsingModes:(NSSet *)modes inYearDate:(NSUInteger)yearDate withConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration
{
    /*
    NSString *dataStr = [self generateStringToExportHeaderWithYear:yearDate andConvertedUserConfiguration:convertedUserConfiguration];

    
    ///////////
    
    
    CGSize pageSize = CGSizeMake(612, 792);
    NSString *pdfFileName = [NSTemporaryDirectory() stringByAppendingPathComponent:kExportPDFVFileNameWithExtension];
    
    UIGraphicsBeginPDFContextToFile(pdfFileName, CGRectZero, nil);
    
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, pageSize.width, pageSize.height), nil);
    
    const NSUInteger kBorderInset = 2;
    const NSUInteger kBorderWidth = 10;

    CGContextRef    currentContext = UIGraphicsGetCurrentContext();

    UIColor *borderColor = [UIColor brownColor];
    CGRect rectFrame = CGRectMake(kBorderInset, kBorderInset, pageSize.width-kBorderInset*2, pageSize.height-kBorderInset*2);
    CGContextSetStrokeColorWithColor(currentContext, borderColor.CGColor);
    CGContextSetLineWidth(currentContext, kBorderWidth);
    CGContextStrokeRect(currentContext, rectFrame);
    
    CGContextSetRGBFillColor(currentContext, 0.0, 0.0, 0.0, 1.0);
    
    NSString *textToDraw = @"Lorem ipsum dolor sit amet.";
    
    const NSUInteger kMarginInset = 10;
    
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    CGRect stringSize = [textToDraw boundingRectWithSize:CGSizeMake(pageSize.width - 2*kBorderInset-2*kMarginInset, pageSize.height - 2*kBorderInset - 2*kMarginInset)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                           NSParagraphStyleAttributeName: paragraphStyle}
                                                 context:nil];
    CGRect renderingRect = CGRectMake(kBorderInset + kMarginInset, kBorderInset + kMarginInset + 50.0, pageSize.width - 2*kBorderInset - 2*kMarginInset, stringSize.size.height);

    NSLog(@"ORIGINAL SIZE %@", NSStringFromCGSize(pageSize));
    NSLog(@"STRING SIZE %@", NSStringFromCGRect(stringSize));
    NSLog(@"RENDERING %@", NSStringFromCGRect(renderingRect));
    
    [textToDraw drawInRect:renderingRect withAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14], NSParagraphStyleAttributeName: paragraphStyle}];
    
    UIGraphicsEndPDFContext();
    
   */
}

@end
