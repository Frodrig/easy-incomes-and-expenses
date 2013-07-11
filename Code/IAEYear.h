//
//  IAEYear.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class IAEMonth;
@class IAECategory;

@interface IAEYear : NSManagedObject

@property (nonatomic) int16_t yearDate;
@property (nonatomic, retain) NSSet *months;
@property (nonatomic, strong) NSArray *ordererMonths;

//- (id)initWithYear:(NSNumber *)yearDate;

- (NSComparisonResult)compare:(IAEYear *)aYear;
- (NSComparisonResult)compareDescendingPriority:(IAEYear *)aYear;

- (NSDecimalNumber *)expenses;
- (NSDecimalNumber *)incomes;
- (NSDecimalNumber *)balance;

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllConcepts;

- (NSUInteger)findNumberOfConcepts;

@end

@interface IAEYear (CoreDataGeneratedAccessors)

- (void)addMonthsObject:(IAEMonth *)value;
- (void)removeMonthsObject:(IAEMonth *)value;
- (void)addMonths:(NSSet *)values;
- (void)removeMonths:(NSSet *)values;

@end
