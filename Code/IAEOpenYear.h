//
//  IAEOpenYear.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEYearObject.h"
#import "MonthDefs.h"

@interface IAEOpenYear : NSObject<IAEYearObject>

@property (nonatomic, readonly) NSInteger yearDate;
@property (nonatomic, strong, readonly) NSArray *years;
@property (nonatomic, strong, readonly) NSArray *months;

- (instancetype)initWithYears:(NSArray *)years andStartMonth:(MonthType)month;

- (void)deleteAllConcepts;

- (NSComparisonResult)compareDescendingPriority:(IAEOpenYear *)aOpenYear;

@end
