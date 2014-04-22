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

- (NSComparisonResult)compare:(IAEMonth *)month;

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
- (IAEConcept *)duplicateConcept:(IAEConcept *)concept;

- (void)deleteAllConcepts; // [self removeAllConceptsWithNotificacion:NO]
- (void)removeAllConceptsWithNotification:(BOOL)notification;
- (void)removeConcept:(IAEConcept *)concept;

- (NSDecimalNumber *)expenses;
- (NSDecimalNumber *)incomes;
- (NSDecimalNumber *)balance;
- (NSDecimalNumber *)total;
- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category;
- (NSDecimalNumber *)sumAllAmountOfCategories:(NSArray *)categories;

- (void)beginCategoryConceptSearchMode;
- (void)endCategoryConceptSearchMode;

- (NSArray *)allConceptsSortedByEntryInstant;
- (NSArray *)allConceptsSortedByDay;
- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllConceptsWithCategoryTag:(NSString *)tag;
- (NSArray *)findAllCategoriesInConceptsOfType:(CategoryType)type;
- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type;

- (NSString *)monthAsString;

- (NSString *)description;

@end

@interface IAEMonth (CoreDataGeneratedAccessors)

- (void)addConceptsObject:(IAEConcept *)value;
- (void)removeConceptsObject:(IAEConcept *)value;
- (void)addConcepts:(NSSet *)values;
- (void)removeConcepts:(NSSet *)values;

@end
