//
//  IAEBook.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 24/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEBook.h"
#import "IAEYear.h"
#import "IAEConcept.h"
#import "IAEMonth.h"
#import "IAEOpenYear.h"
#import "MonthDefs.h"
#import "NSUserDefaults+EasyIncAndExp.h"
#import <Crashlytics/Crashlytics.h>

@interface IAEBook()

@property (nonatomic, strong) NSMutableArray *years;
@property (nonatomic, strong) NSManagedObjectContext *context;
@property (nonatomic, strong) NSManagedObjectModel *model;
@end

@implementation IAEBook

#pragma mark - Constantes

static NSString * const kFileNameForStoreData = @"incomeandexpenses.data";

#pragma mark - Singleton

+ (IAEBook *)sharedBook
{
    static IAEBook *sharedBook = nil;
    if (!sharedBook) {
        sharedBook = [[super allocWithZone:nil] init];
    }
    
    return sharedBook;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedBook];
}

#pragma mark - Instance

- (id)init
{
    self = [super init];
    if (self) {
        [self prepareModelAndContextOfDB];
        [self prepareYearContainers];
    }
    
    return self;
}

- (void)prepareModelAndContextOfDB
{
    _model = [NSManagedObjectModel mergedModelFromBundles:nil];
    NSPersistentStoreCoordinator *persistentStore = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:_model];
    
    NSError *error;
    if (![persistentStore addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:[self storeFileURLWithPath]
                                             options:nil
                                               error:&error]) {
        [NSException raise:@"Open DB failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    _context = [[NSManagedObjectContext alloc] init];
    _context.persistentStoreCoordinator = persistentStore;
    _context.undoManager = nil;
}


- (NSManagedObjectModel *)createManagedObjectModel
{
    return [NSManagedObjectModel mergedModelFromBundles:nil];
}

- (NSManagedObjectContext *)createManagedObjectContextFromModel:(NSManagedObjectModel *)model
{
    NSPersistentStoreCoordinator *persistentStore = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    
    NSURL *storeURL = [self storeFileURLWithPath];
    
    NSError *error;
    if (![persistentStore addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:nil
                                               error:&error]) {
        [NSException raise:@"Open DB failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] init];
    context.persistentStoreCoordinator = persistentStore;
    context.undoManager = nil;

    return context;
}

- (void)prepareYearContainers
{
    _years = [NSMutableArray array];
    _openYears = [NSArray array];
}

- (NSURL *)storeFileURLWithPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSURL* retURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:kFileNameForStoreData]];
    
    return retURL;
}

- (void)doRefreshObjectMergeChangesExceptForObjects:(NSSet *)exceptObjects
{
    for (IAEYear *yearIt in self.years) {
        BOOL refresh = exceptObjects == nil;
        if (!refresh) {
            refresh = ![exceptObjects containsObject:yearIt];
        }
        
        if (refresh) {
            for (IAEMonth *monthIt in yearIt.months) {
                for (IAEConcept *conceptIt in monthIt.concepts) {
                    [self.context refreshObject:conceptIt mergeChanges:NO];
                }
                [self.context refreshObject:monthIt mergeChanges:NO];
            }
            [self.context refreshObject:yearIt mergeChanges:NO];
        }
    }
}

- (IAEOpenYear *)openYear:(NSNumber *)yearDate
{
    IAEOpenYear *openYear = nil;
    
    const BOOL isPresentOrPastYearDate = [self isPresentOrPastYearTheYearDate:yearDate.unsignedIntegerValue];
    if (isPresentOrPastYearDate) {
        const NSUInteger firstYearDate = yearDate.unsignedIntegerValue;
        const NSUInteger secondYearDate = yearDate.unsignedIntegerValue + 1;
        
        IAEYear *firstYear = [self findLoadOrCreateYearObjectWithDate:firstYearDate];
        IAEYear *secondYear = [self findLoadOrCreateYearObjectWithDate:secondYearDate];
        openYear = [self findOrCreateOpenYearObjectWithFirstYear:firstYear andSecondYear:secondYear];
    }
    
    return openYear;
}

- (BOOL)isPresentOrPastYearTheYearDate:(NSUInteger)yearDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *components = [gregorian components:NSYearCalendarUnit fromDate:[NSDate date]];
    const BOOL isPresentOrPastYearDate = yearDate <= components.year;
    
    return isPresentOrPastYearDate;
}

- (IAEYear *)findLoadOrCreateYearObjectWithDate:(NSUInteger)yearDate
{
    IAEYear *year = [self findYearObjectWithDate:yearDate];
    
    if (!year) {
        year = [self loadYearObjectWithDate:yearDate];
    }
    
    if (!year) {
        year = [self createYearObjectWithDate:yearDate];
    }
    
    return year;
}

- (IAEYear *)findYearObjectWithDate:(NSUInteger)yearDate
{
    __block IAEYear *year = nil;
    [self.years enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEYear *yearObjectIt = obj;
        *stop = yearObjectIt.yearDate == yearDate;
        if (*stop) {
            year = yearObjectIt;
        }
    }];
    
    return year;
}

- (IAEYear *)loadYearObjectWithDate:(NSUInteger)yearDate
{
    NSAssert(![self findYearObjectWithDate:yearDate], @"");
    
    IAEYear *yearObject = nil;
    
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"yearDate == %d", yearDate];
    NSArray *searchResult = [self loadYearsWithLimit:1 andPredicate:searchPredicate];
    if (searchResult.count == 1) {
        yearObject = searchResult[0];
        [self addYearObject:yearObject];
    }
    
    return yearObject;
}

- (void)addYearObject:(IAEYear *)year
{
    NSAssert([self.years indexOfObject:year] == NSNotFound, @"");
    
    [_years addObject:year];
    [_years sortUsingSelector:@selector(compareDescendingPriority:)];
}

- (IAEYear *)createYearObjectWithDate:(NSUInteger)yearDate
{
    NSAssert(![self findYearObjectWithDate:yearDate], @"");
    NSAssert(![self loadYearObjectWithDate:yearDate], @"");
    
    IAEYear *newYear = [NSEntityDescription insertNewObjectForEntityForName:@"IAEYear" inManagedObjectContext:self.context];
    newYear.yearDate = yearDate;
    [self addYearObject:newYear];
    
    return newYear;
}

- (NSArray *)loadYearsWithLimit:(NSUInteger)limit andPredicate:(NSPredicate *)predicate
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [[self.model entitiesByName] objectForKey:@"IAEYear"];
    request.sortDescriptors = [NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"yearDate" ascending:NO]];
    request.fetchLimit = limit;
    request.predicate = predicate;
    
    NSError *error;
    NSArray *yearsLoaded = [self.context executeFetchRequest:request error:&error];
    if (!yearsLoaded) {
        CLS_LOG(@"Fallo haciendo fetch de años. Razon %@", [error localizedDescription]);
        [NSException raise:@"Fetch failed loading years" format:@"Reason: %@", [error localizedDescription]];
    }
    
    return yearsLoaded;
}

- (IAEOpenYear *)findOrCreateOpenYearObjectWithFirstYear:(IAEYear *)firstYear andSecondYear:(IAEYear *)secondYear
{
    IAEOpenYear *openYear = [self findOpenYearObjectWithDate:firstYear.yearDate];
    
    if (!openYear) {
        MonthType startMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
        IAEOpenYear *openYear = [[IAEOpenYear alloc] initWithYears:@[firstYear, secondYear] andStartMonth:startMonth];
        _openYears = _openYears ? [_openYears arrayByAddingObject:openYear] : [NSArray arrayWithObject:openYear];
        _openYears = [self.openYears sortedArrayUsingSelector:@selector(compareDescendingPriority:)];
    }
    
    return openYear;
}

- (IAEOpenYear *)findOpenYearObjectWithDate:(NSUInteger)yearDate
{
    __block IAEOpenYear *openYear = nil;
    [self.openYears enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAEOpenYear *openYearIt = obj;
        *stop = openYearIt.yearDate == yearDate;
        if (*stop) {
            openYear = openYearIt;
        }
    }];
    
    return openYear;
}

- (void)closeYearWithYearDate:(NSUInteger)yearDate
{
    [self removeOpenYearObjectWithoutUnloadYearObjectsWithDate:yearDate];
    
    [self unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:yearDate];
    [self unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:yearDate + 1];
}

- (void)removeOpenYearObjectWithoutUnloadYearObjectsWithDate:(NSUInteger)yearDate
{
    IAEOpenYear *openYear = [self findOpenYearObjectWithDate:yearDate];
    NSMutableArray *newOpenYear = [NSMutableArray arrayWithArray:self.openYears];
    [newOpenYear removeObject:openYear];
    
    self.openYears = [NSArray arrayWithArray:newOpenYear];
}

- (void)unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:(NSUInteger)yearDate
{
    IAEYear *yearObject = [self findYearObjectWithDate:yearDate];
    if (yearObject) {
        NSArray *openYearsWithReferences = [self findOpenYearsObjectsWithReferencesToYearObject:yearObject];
        const BOOL canUnloadOrDestroy = openYearsWithReferences.count <= 1;
        
        if (canUnloadOrDestroy) {
            const NSUInteger numberOfConcepts = [yearObject findNumberOfConcepts];
            const BOOL permanentDelete = 0 == numberOfConcepts;
            [self deleteYearObject:yearObject permanent:permanentDelete];
        }
    }
}

- (void)deleteYearObject:(IAEYear *)year permanent:(BOOL)permanent
{
    [self.years removeObject:year];
    [self doRefreshObjectMergeChangesExceptForObjects:[NSSet setWithArray:self.years]];
    if (permanent) {
        [self.context deleteObject:year];
    }
}

- (NSArray *)findOpenYearsObjectsWithReferencesToYearObject:(IAEYear *)yearObject
{
    NSMutableArray *openYearReferencesFound = [NSMutableArray arrayWithCapacity:self.openYears.count];
    for (IAEOpenYear *openYear in self.openYears) {
        if ([openYear.years indexOfObject:yearObject] != NSNotFound) {
            [openYearReferencesFound addObject:openYear];
        }
    }
    
    NSArray *result = [NSArray arrayWithArray:openYearReferencesFound];
    return result;
}

- (void)openAll
{
    [self closeAll];

    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:UINT_MAX andPredicate:nil]];
    
    NSMutableArray *allExistingYearsDates = [[NSMutableArray alloc] initWithCapacity:_years.count];
    for (IAEYear *year in _years) {
        [allExistingYearsDates addObject:@(year.yearDate)];
    }
    
    for (NSNumber *yearDate in allExistingYearsDates) {
        [self openYear:yearDate];
    }
}

- (void)closeAll
{
    while (self.openYears.count > 0) {
        IAEOpenYear *openYear = [self.years objectAtIndex:0];
        [self closeYearWithYearDate:openYear.yearDate];
    }
}

- (void)saveAndCloseAllAndOpenYearWithDate:(NSNumber *)yearDate
{
    [self saveAll];
    [self closeAllAndOpenYearWithDate:yearDate];
}

- (void)closeAllAndOpenYearWithDate:(NSNumber *)yearDate
{
    [self closeAll];
    [self openYear:yearDate];
}

- (void)openMostRecientCreatedYear
{
    NSArray *twoLastYears = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:nil]];
    for (IAEYear *year in twoLastYears) {
        if ([self isPresentOrPastYearTheYearDate:year.yearDate]) {
            [self openYear:@(year.yearDate)];
            break;
        }
    }
}

- (BOOL)saveAll
{
    NSError *error = nil;
    BOOL saveResult = [self.context save:&error];
    if (!saveResult) {
        [NSException raise:@"Error saving" format:@"Reason %@", [error localizedDescription]];
    }
    
    return saveResult;
}

- (void)deleteAllAndSave
{
    [self saveAll];
    [self openAll];
    self.openYears = [NSArray array];
    while (self.years.count > 0) {
        IAEYear *yearObject = self.years[0];
        [self deleteYearObject:yearObject permanent:YES];
    }
    [self.years removeAllObjects];
}

#pragma mark - Find

- (IAEOpenYear *)findOpenYearWithDate:(NSNumber *)yearDate
{
    NSAssert(yearDate.unsignedIntegerValue, @"");
    
    IAEOpenYear *resultYear = nil;
    for (IAEOpenYear *year in self.openYears) {
        if (year.yearDate == yearDate.unsignedIntegerValue) {
            resultYear = year;
            break;
        }
    }
    
    // ¿Si no lo encuentra lo creamos?
    
    return resultYear;
}

- (NSArray *)findAllYeardDatesLoaded
{
    NSMutableArray *allYearDates = [[NSMutableArray alloc] initWithCapacity:self.years.count];
    for (IAEYear *yearIt in self.years) {
        [allYearDates addObject:@(yearIt.yearDate)];
    }
    
    return [NSArray arrayWithArray:allYearDates];
}

- (NSArray *)findInOpenYearsAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.openYears.count];
    for (IAEOpenYear *openYear in self.openYears) {
        NSArray *allConceptsOfOpenYear = [openYear findAllConceptsWithCategory:category];
        [concepts addObjectsFromArray:allConceptsOfOpenYear];
    }
    
    return concepts;
}

- (NSArray *)findAllOpenYearsWithConcepts
{
    NSMutableArray *yearsSelected = [NSMutableArray arrayWithCapacity:self.openYears.count];
    for (IAEOpenYear *openYear in self.openYears) {
        const NSUInteger numberOfConceptsInOpenYear = [openYear findNumberOfConcepts];
        if (numberOfConceptsInOpenYear > 0) {
            [yearsSelected addObject:openYear];
        }
    }
    
    NSArray *resultOpenYears = [NSArray arrayWithArray:yearsSelected];
    return resultOpenYears;
}

- (IAEOpenYear *)findActualOpenYear
{
    // Siempre se considera que el año actualmente abierto es el primero
    NSAssert(self.openYears.count >= 1, @"O no hay años o bien hay mas de uno cargado");
    return [self.openYears objectAtIndex:0];
}

//////
/*
- (NSArray *)findAllYeardDatesLoaded
{
    NSMutableArray *allYearDates = [[NSMutableArray alloc] initWithCapacity:self.years.count];
    for (IAEYear *yearIt in self.years) {
        [allYearDates addObject:@(yearIt.yearDate)];
    }
    
    return [NSArray arrayWithArray:allYearDates];
}

- (IAEYear *)findActualYear
{
    // Cuando estamos fuera de la pantalla de seleccion de año solo hay un año cargado y es el primero del array
    NSAssert(self.years.count != 0, @"¡No hay años cargados!");
    return self.years.count > 0 ? [self.years objectAtIndex:0] : nil;
}

// Nota: Preserva siempre el año actual aunque no tenga conceptos
- (void)loadAllYearsRemovingYearsWithZeroConceptsAndPreservingActualYear
{
    IAEYear *actualYearObjectBeforeReload = [self findActualYear];
    const NSUInteger actualYearDate = actualYearObjectBeforeReload.yearDate;
    if (actualYearObjectBeforeReload) {
        [self loadAll];
        
        // Garantizamos que el año que estaba abierto seguira ocupando la primera posicion
        IAEYear *actualYearAfterReload = [self findYearWithDate:@(actualYearDate)];
        NSUInteger actualYearIndex = [self.years indexOfObject:actualYearAfterReload];
        NSAssert(actualYearIndex != NSNotFound, @"");
        if (actualYearIndex != 0) {
            [self.years exchangeObjectAtIndex:0 withObjectAtIndex:actualYearIndex];
        }
        
        NSMutableSet *yearsToDelete = [[NSMutableSet alloc] initWithCapacity:self.years.count];
        for (IAEYear *year in self.years) {
            if ([year findNumberOfConcepts] == 0 && actualYearDate != year.yearDate) {
                [yearsToDelete addObject:year];
            }
        }
        
        while (yearsToDelete.count > 0) {
            IAEYear *yearObjectToDelete = [yearsToDelete anyObject];
            [yearsToDelete removeObject:yearObjectToDelete];
            [self deleteYearObject:yearObjectToDelete];
        }
    }
}

- (void)unloadAllAndLoadYearDates:(NSArray *)yearDates
{
    [self unloadAll];
    
    NSMutableArray *yearsLoaded = [NSMutableArray arrayWithCapacity:yearDates.count];
    
    for (NSNumber *yearDateIt in yearDates) {
        NSArray *yearLoaded = [self loadYearsWithLimit:1 andPredicate:[NSPredicate predicateWithFormat:@"yearDate == %@", yearDateIt]];
        [yearsLoaded addObjectsFromArray:yearLoaded];
    }
    
    self.years = yearsLoaded;
}

- (void)loadMoreRecientYear
{
    [self doRefreshObjectMergeChangesExceptForObjects:nil];
    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:nil]];
}

- (void)loadYear:(NSUInteger)year
{
    IAEYear *yearFound = nil;
    for (IAEYear *yearIt in self.years) {
        if (yearIt.yearDate == year) {
            yearFound = yearIt;
            break;
        }
    }
    
    if (yearFound) {
        [self doRefreshObjectMergeChangesExceptForObjects:[NSSet setWithObject:yearFound]];
        _years = [NSMutableArray arrayWithObject:yearFound];
    } else {
        [self doRefreshObjectMergeChangesExceptForObjects:nil];
        _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:[NSPredicate predicateWithFormat:@"yearDate == %@", [NSNumber numberWithUnsignedInteger:year]]]];
    }
}

- (void)loadAll
{
    [self doRefreshObjectMergeChangesExceptForObjects:[NSSet setWithArray:self.years]];
    
    NSArray *years = [self loadYearsWithLimit:UINT_MAX andPredicate:nil];
    if (years) {
        _years = [NSMutableArray arrayWithArray:years];
    }
}

- (instancetype)initWithManagedObjectModel:(NSManagedObjectModel *)model andManagedObjectContext:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        _model = model;
        _context = context;
    }
    
    return self;
}
*/
@end
