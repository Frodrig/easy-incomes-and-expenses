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

@class IAEOpenYear;
@class IAEYear;
@class IAECategory;

@interface IAEBook : NSObject

@property (nonatomic, strong) NSArray *openYears;
@property (nonatomic, readonly, strong) NSManagedObjectContext *context;
@property (nonatomic, readonly, strong) NSManagedObjectModel *model;

+ (IAEBook *)sharedBook;

- (void)openAll;
- (void)openMoreRecientYear;
- (void)closeAll;

//- (void)loadAll;
//- (void)loadYear:(NSUInteger)yearDate;
//- (void)loadMoreRecientYear;
//- (void)unloadAll;
- (IAEOpenYear *)closeAllAndOpenYear:(NSNumber *)yearDate;
- (IAEOpenYear *)openYear:(NSNumber *)yearDate;
- (void)deleteAllConceptsOfOpenYear:(IAEOpenYear *)year;
- (void)closeAllOpenYearsPreservingActualYear;

//- (IAEYear *)createYear:(NSNumber *)yearDate;
//- (void)deleteYear:(NSNumber *)yearDate;
//- (void)deleteYearsWithZeroConceptsPreservingActualYear;
//- (void)deleteAllConceptsOfYear:(IAEYear *)year;

// OJO: La funcion mas destructiva
/*
- (IAEYear *)findYearWithDate:(NSNumber *)yearDate;
- (IAEYear *)findActualYear;
- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllYearWithConcepts;
*/

- (IAEOpenYear *)findOpenYearWithDate:(NSNumber *)yearDate;
- (IAEOpenYear *)findActualOpenYear;
- (NSArray *)findInOpenYearsAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllOpenYearsWithConcepts;

- (BOOL)saveAll;

- (void)deleteAllAndSave;

@end
