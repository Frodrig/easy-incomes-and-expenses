//
//  IAEExporter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporter.h"
#import "IAEBook.h"
#import "IAEOpenYear.h"
#import "IAEMonth.h"
#import "IAEDateHelper.h"
#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAEYear.h"
#import "IAENumberFormatterManager.h"

@implementation IAEExporter

#pragma mark - Constants

static NSString * const kCSVCommaSeparator = @",";
static NSString * const kExportCSVFileWithExtension = @"export.csv";

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

- (BOOL)exportAllYearsToTMPCSVFile
{
    BOOL exportOk = NO;
    
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:kExportCSVFileWithExtension];
    [[NSFileManager defaultManager] removeItemAtPath:pathForTMPDirectory error:nil];
    const BOOL fileManagerOk = [[NSFileManager defaultManager] createFileAtPath:pathForTMPDirectory contents:nil attributes:nil];
    if (fileManagerOk) {
        NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:pathForTMPDirectory];
        const BOOL fileHandleOk = fileHandle != nil;
        if (fileHandleOk) {
            [fileHandle seekToEndOfFile];
            [self writeCSVToFile:fileHandle];
            [fileHandle closeFile];
            exportOk = YES;
        } else {
            // TODO: Fallo creando el FileHandle
        }
    } else {
        // TODO: Fallo creando el FileManager
    }
    
    return exportOk;
}

- (void)writeCSVToFile:(NSFileHandle *)fileHandle
{
    [self writeHeaderColumnsToCSVWithFileHandle:fileHandle];
    [self writeAllConceptsToCSVWithFileHandle:fileHandle];
}

- (void)writeHeaderColumnsToCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    NSString *headerStr = NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_YEAR", "");
    headerStr = [headerStr stringByAppendingString:kCSVCommaSeparator];
    headerStr = [headerStr stringByAppendingString:NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_MONTH", "")];
    headerStr = [headerStr stringByAppendingString:kCSVCommaSeparator];
    headerStr = [headerStr stringByAppendingString:NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_DAY", "")];
    headerStr = [headerStr stringByAppendingString:kCSVCommaSeparator];
    headerStr = [headerStr stringByAppendingString:NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_TYPE", "")];
    headerStr = [headerStr stringByAppendingString:kCSVCommaSeparator];
    headerStr = [headerStr stringByAppendingString:NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_CATEGORY", "")];
    headerStr = [headerStr stringByAppendingString:kCSVCommaSeparator];
    headerStr = [headerStr stringByAppendingString:NSLocalizedString(@"LTEXT_EXPORTCSV_COLUMN_AMOUNT", "")];
    
    NSData *data = [headerStr dataUsingEncoding:NSUnicodeStringEncoding];
    [fileHandle writeData:data];
}

- (void)writeAllConceptsToCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    IAEOpenYear *actualOpenYear = [[IAEBook sharedBook] findActualOpenYear];
    NSNumber *actualOpenYearDate = @(actualOpenYear.yearDate);
    
    [[IAEBook sharedBook] openAll];
    
    for (IAEOpenYear *openYear in [IAEBook sharedBook].openYears) {
        for (IAEMonth *month in openYear.months) {
            NSArray *ordererConcepts = [month allConceptsSortedByDay];
            for (IAEConcept *concept in [ordererConcepts reverseObjectEnumerator]) {
                [self writeConcept:concept toCSVWithFileHandle:fileHandle];
            }
        }
    }
    
    [[IAEBook sharedBook] closeAllAndOpenYearWithDate:actualOpenYearDate];
}

- (void)writeConcept:(IAEConcept *)concept toCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    NSString *openYearStr = [NSString stringWithFormat:@"%d", concept.month.year.yearDate];
    NSString *monthString = [IAEDateHelper findMonthNameStringWithMonthIndex:concept.month.month inShortForm:NO];

    NSString *conceptToWrite = @"\n";
    
    conceptToWrite = [[conceptToWrite stringByAppendingString:openYearStr] stringByAppendingString:kCSVCommaSeparator];
    
    conceptToWrite = [[conceptToWrite stringByAppendingString:monthString] stringByAppendingString:kCSVCommaSeparator];
    
    if (concept.dayOfTheMonth != 0) {
        conceptToWrite = [conceptToWrite stringByAppendingString:[NSString stringWithFormat:@"%d", concept.dayOfTheMonth]];
    }
    conceptToWrite = [conceptToWrite stringByAppendingString:kCSVCommaSeparator];
    
    NSString *categoryTypeStr = concept.category.categoryType == IncomeCategory ? NSLocalizedString(@"LTEXT_EXPORTCSV_CATEGORY_INCOME", "") : NSLocalizedString(@"LTEXT_EXPORTCSV_CATEGORY_EXPENSE", "");
    conceptToWrite = [[conceptToWrite stringByAppendingString:categoryTypeStr] stringByAppendingString:kCSVCommaSeparator];
    
    NSString *categoryTag = [concept.category localizedTag];
    categoryTag = [categoryTag stringByReplacingOccurrencesOfString:@"," withString:@"\",\""];
    categoryTag = [categoryTag stringByAppendingString:kCSVCommaSeparator];
    conceptToWrite = [conceptToWrite stringByAppendingString:categoryTag];
    
    NSNumberFormatter *formatter = [IAENumberFormatterManager sharedManager].currencyFormatter;
    NSString *categoryAmount = [formatter stringFromNumber:concept.amountWithSign];
    categoryAmount = [categoryAmount stringByReplacingOccurrencesOfString:@"," withString:@"\",\""];
    conceptToWrite = [conceptToWrite stringByAppendingString:categoryAmount];
    
    NSData *dataToWrite = [conceptToWrite dataUsingEncoding:NSUnicodeStringEncoding];
    [fileHandle writeData:dataToWrite];
}


- (NSData *)dataOfTMPCSVFile
{
    NSData *fileData = nil;
    
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:kExportCSVFileWithExtension];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:pathForTMPDirectory];
    const BOOL fileHandleOk = fileHandle != nil;
    if (fileHandleOk) {
        fileData = [fileHandle readDataToEndOfFile];
    }
    
    return fileData;
}

@end
