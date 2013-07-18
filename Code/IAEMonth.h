//
//  IAEMonth.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "MonthDefs.h"
#import "IAEMonthDelegate.h"
#import "CategoryDefs.h"

@class IAEConcept, IAEYear;

@interface IAEMonth : NSManagedObject

@property (nonatomic) int16_t month;
@property (nonatomic, retain) NSSet *concepts;
@property (nonatomic, retain) IAEYear *year;

@property (nonatomic, weak) id<IAEMonthDelegate> delegate;

- (NSDecimalNumber *)daysOfTheMonth;

- (IAEConcept *)addConceptWithAmount:(NSDecimalNumber *)amount
                            category:(IAECategory *)category
                                date:(NSTimeInterval)date
                      andDescription:(NSString *)description;

- (IAEConcept *)addConceptWithAmount:(NSDecimalNumber *)amount
                            category:(IAECategory *)category
                                date:(NSTimeInterval)date
                       dayOfTheMonth:(NSUInteger)dayOfTheMonth
                      andDescription:(NSString *)description;

- (void)removeConcept:(IAEConcept *)concept;

- (NSDecimalNumber *)expenses;
- (NSDecimalNumber *)incomes;
- (NSDecimalNumber *)balance;
- (NSDecimalNumber *)total;
- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category;

- (NSArray *)allConceptsSortedByEntryInstant;
- (NSArray *)allConceptsSortedByDay;

- (NSDecimalNumber *)sumAllAmountOfCategories:(NSArray *)categories;
- (NSArray *)findAllCategoriesInConceptsOfType:(CategoryType)type;
- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type;

- (NSString *)description;

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllConceptsWithCategoryTag:(NSString *)tag;

@end

@interface IAEMonth (CoreDataGeneratedAccessors)

- (void)addConceptsObject:(IAEConcept *)value;
- (void)removeConceptsObject:(IAEConcept *)value;
- (void)addConcepts:(NSSet *)values;
- (void)removeConcepts:(NSSet *)values;

@end
