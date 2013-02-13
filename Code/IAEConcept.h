//
//  IAEConcept.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IAECategory, IAEMonth;

@interface IAEConcept : NSManagedObject

@property (nonatomic, retain) NSDecimalNumber * amount;
@property (nonatomic) NSTimeInterval date;
@property (nonatomic) int16_t dayOfTheMonth;
@property (nonatomic, retain) NSString * detailDescription;
@property (nonatomic, retain) IAECategory *category;
@property (nonatomic, retain) IAEMonth *month;

@end
