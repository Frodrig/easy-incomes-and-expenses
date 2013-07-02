//
//  IAEInputConceptsDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 07/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEMonth;

@protocol IAEInputConceptsDataSource <NSObject>

- (IAEMonth *)actualSelectedMonth;

@end
