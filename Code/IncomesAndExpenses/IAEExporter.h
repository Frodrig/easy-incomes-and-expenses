//
//  IAEExporter.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEExporter : NSObject

+ (IAEExporter *)sharedExporter;

- (BOOL)exportAllYearsToTMPCSVFile;

- (void)exportYearDate:(NSUInteger)yearDate withUserConfiguration:(NSDictionary *)userConfiguration;

@end
