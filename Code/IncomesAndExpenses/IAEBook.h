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
- (IAEOpenYear *)openYear:(NSNumber *)yearDate;

- (void)closeAll;
- (void)saveAndCloseAllAndOpenYearWithDate:(NSNumber *)yearDate;
- (void)closeAllAndOpenYearWithDate:(NSNumber *)yearDate;

- (IAEOpenYear *)findActualOpenYear;
- (IAEOpenYear *)findOpenYearWithDate:(NSNumber *)yearDate;
- (NSArray *)findInOpenYearsAllConceptsWithCategory:(IAECategory *)category;
- (NSArray *)findAllOpenYearsWithConcepts;

- (NSArray *)findAllYeardDatesLoaded;

- (BOOL)saveAll;

- (void)deleteAllAndSave;

@end
