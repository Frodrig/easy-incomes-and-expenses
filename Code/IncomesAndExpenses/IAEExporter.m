//
//  IAEExporter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporter.h"
#import "IAEExporterDefs.h"
#import "IAEBook.h"
#import "IAEOpenYear.h"
#import "IAEMonth.h"
#import "IAEDateHelper.h"
#import "IAEConcept.h"
#import "IAECategory.h"
#import "IAEYear.h"
#import "IAENumberFormatterManager.h"

@interface IAEExporter()
@property (nonatomic, strong) NSFileHandle *exportFileHandle;
@end

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

- (BOOL)beginExport
{
    NSString * pathForTMPDirectory = [NSTemporaryDirectory() stringByAppendingPathComponent:kExportCSVFileWithExtension];
    [[NSFileManager defaultManager] removeItemAtPath:pathForTMPDirectory error:nil];
    if ([[NSFileManager defaultManager] createFileAtPath:pathForTMPDirectory contents:nil attributes:nil]) {
        self.exportFileHandle = [NSFileHandle fileHandleForWritingAtPath:pathForTMPDirectory];
    }

    return self.exportFileHandle != nil;
}

- (void)endExport
{
    NSAssert(self.exportFileHandle, @"");
    [self.exportFileHandle closeFile];
}

- (BOOL)exportAllYearsToTMPCSVFile
{
    const BOOL retExportOk = [self beginExport];
    if (retExportOk) {
        [self writeHeaderColumnsToCSVWithFileHandle:self.exportFileHandle];
        [self writeAllConceptsOfAllYearsToCSVWithFileHandle:self.exportFileHandle];
    }
    [self endExport];
    
    return retExportOk;
}

- (BOOL)exporToTMPCSVFileYear:(NSUInteger)year
{
    BOOL retExportOk = [self beginExport];
    if (retExportOk) {
        IAEOpenYear *actualOpenYear = [[IAEBook sharedBook] findActualOpenYear];
        NSNumber *actualOpenYearDate = @(actualOpenYear.yearDate);
        IAEOpenYear *openYearToExport = [[IAEBook sharedBook] openYear:@(year)];
        if (openYearToExport) {
            [self writeHeaderColumnsToCSVWithFileHandle:self.exportFileHandle];
            [self writeAllConceptsOfYear:openYearToExport toCSVWithFileHandle:self.exportFileHandle];
        } else {
            retExportOk = NO;
        }
        [[IAEBook sharedBook] openYear:actualOpenYearDate];
    }
    [self endExport];
    
    return retExportOk;
}

- (BOOL)exportFromActualOpenYearToTMPCSVFileMonth:(MonthType)month
{
    BOOL retExportOk = [self beginExport];
    if (retExportOk) {
        IAEOpenYear *actualOpenYear = [[IAEBook sharedBook] findActualOpenYear];
        IAEMonth *monthToExport = [actualOpenYear findMonthObjectOfMonthDate:month];
        if (monthToExport) {
            [self writeHeaderColumnsToCSVWithFileHandle:self.exportFileHandle];
            [self writeAllConceptsOfMonth:monthToExport toCSVWithFileHandle:self.exportFileHandle];
        } else {
            retExportOk = NO;
        }
    }
    [self endExport];
    
    return retExportOk;
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

- (void)writeAllConceptsOfAllYearsToCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    IAEOpenYear *actualOpenYear = [[IAEBook sharedBook] findActualOpenYear];
    NSNumber *actualOpenYearDate = @(actualOpenYear.yearDate);
    
    [[IAEBook sharedBook] openAll];
    for (IAEOpenYear *openYear in [IAEBook sharedBook].openYears) {
        [self writeAllConceptsOfYear:openYear toCSVWithFileHandle:fileHandle];
    }
    
    [[IAEBook sharedBook] closeAllAndOpenYearWithDate:actualOpenYearDate];
}

- (void)writeAllConceptsOfYear:(IAEOpenYear *)year toCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    for (IAEMonth *month in year.months) {
        [self writeAllConceptsOfMonth:month toCSVWithFileHandle:fileHandle];
    }
}

- (void)writeAllConceptsOfMonth:(IAEMonth *)month toCSVWithFileHandle:(NSFileHandle *)fileHandle
{
    NSArray *ordererConcepts = [month allConceptsSortedByDay];
    for (IAEConcept *concept in [ordererConcepts reverseObjectEnumerator]) {
        [self writeConcept:concept toCSVWithFileHandle:fileHandle];
    }
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
@end
