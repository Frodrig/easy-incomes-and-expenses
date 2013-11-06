//
//  IAEExporterWritter.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 06/11/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//
// Ver IAEExporterConverter para conocer el formato en el que llega la configuracion del usuario convertida

#import <Foundation/Foundation.h>

@interface IAEExporterWritter : NSObject

+ (void)exportToCSVUsingModes:(NSSet *)modes inYearDate:(NSUInteger)yearDate withConvertedUserConfiguration:(NSDictionary *)convertedUserConfiguration;

@end
