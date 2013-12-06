//
//  IAEExporter.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEExporter.h"
#import "IAEExporterConverter.h"
#import "IAEExporterWritter.h"
#import "IAEExporterDefs.h"

@implementation IAEExporter

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
    
    NSDictionary *convertedData = [IAEExporterConverter convertToExportDataFromYearDate:yearDate andUserConfiguration:userConfiguration];
    
    NSSet *modes = userConfiguration[kKeyWhatOptions];
    
    const BOOL exportToCSV = [userConfiguration[kKeyWhereCSV] boolValue];
    if (exportToCSV) {
        [IAEExporterWritter exportToCSVUsingModes:modes inYearDate:yearDate withConvertedUserConfiguration:convertedData];
    }
    
    const BOOL exportToPDF = [userConfiguration[kKeyWherePDF] boolValue];
    if (exportToPDF) {
        [IAEExporterWritter exportToPDFUsingModes:modes inYearDate:yearDate withConvertedUserConfiguration:convertedData];
    }
    
    const BOOL exportToPrint = [userConfiguration[kKeyWherePrint] boolValue];
    if (exportToPrint) {
        
    }
}

@end
