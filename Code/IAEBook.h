//
//  IAEBook.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 24/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//
// Nota: IAEBook works always with the loaded years. If you have only one year loaded all operations of, for example, type "find" will work with that
// year only.

#import <Foundation/Foundation.h>

@class IAEYear;
@class IAECategory;

@interface IAEBook : NSObject

@property (nonatomic, readonly, strong) NSMutableArray *years;
@property (nonatomic, readonly, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly, strong) NSManagedObjectModel *model;

+ (IAEBook *)sharedBook;

- (IAEYear *)createYear:(NSNumber *)yearDate;
- (void)deleteYear:(NSNumber *)yearDate;
- (void)deleteYearsWithZeroConceptsPreservingActualYear;

- (void)deleteAllConceptsOfYear:(IAEYear *)year;

- (IAEYear *)findYearWithDate:(NSNumber *)yearDate;
- (IAEYear *)findActualYear;

- (BOOL)saveAll;

- (void)loadAll;
- (void)loadYear:(NSUInteger)yearDate;
- (void)loadMoreRecientYear;
- (void)unloadAll;

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllYearWithConcepts;

@end
