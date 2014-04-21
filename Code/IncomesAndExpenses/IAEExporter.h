//
//  IAEExporter.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MonthDefs.h"

@interface IAEExporter : NSObject

+ (IAEExporter *)sharedExporter;

- (BOOL)exportAllYearsToTMPCSVFile;
- (BOOL)exporToTMPCSVFileYear:(NSUInteger)year;
- (BOOL)exportFromActualOpenYearToTMPCSVFileMonth:(MonthType)month;

@end
