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
    
    _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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
    
    NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
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
    
    const BOOL isPresentOrPastYearDate = true;//[self isPresentOrPastYearTheYearDate:yearDate.unsignedIntegerValue];
    if (isPresentOrPastYearDate) {
        const NSUInteger firstYearDate = yearDate.unsignedIntegerValue;
        const NSUInteger secondYearDate = yearDate.unsignedIntegerValue + 1;
        
        IAEYear *firstYear = [self findLoadOrCreateYearObjectWithDate:firstYearDate];
        IAEYear *secondYear = [self findLoadOrCreateYearObjectWithDate:secondYearDate];
        openYear = [self findOrCreateOpenYearObjectWithFirstYear:firstYear andSecondYear:secondYear];
        
    }/* else if (![self findYearObjectWithDate:yearDate.unsignedIntegerValue]) {
        // future year that doesnt exist
        const NSUInteger firstYearDate = yearDate.unsignedIntegerValue;
        const NSUInteger secondYearDate = yearDate.unsignedIntegerValue + 1;

        IAEYear *firstYear = [self findLoadOrCreateYearObjectWithDate:firstYearDate];
        IAEYear *secondYear = [self findLoadOrCreateYearObjectWithDate:secondYearDate];
        openYear = [self findOrCreateOpenYearObjectWithFirstYear:firstYear andSecondYear:secondYear];
    } else {
        openYear = [self findOpenYearWithDate:yearDate];
    }*/
    
    return openYear;
}

- (BOOL)isPresentOrPastYearTheYearDate:(NSUInteger)yearDate
{
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [gregorian components:NSCalendarUnitYear fromDate:[NSDate date]];
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
        [NSException raise:@"Fetch failed loading years" format:@"Reason: %@", [error localizedDescription]];
    }
    
    return yearsLoaded;
}

- (IAEOpenYear *)findOrCreateOpenYearObjectWithFirstYear:(IAEYear *)firstYear andSecondYear:(IAEYear *)secondYear
{
    IAEOpenYear *openYear = [self findOpenYearObjectWithDate:firstYear.yearDate];
    
    if (!openYear) {
        MonthType startMonth = [[NSUserDefaults standardUserDefaults] actualInitialMonth];
        openYear = [[IAEOpenYear alloc] initWithYears:@[firstYear, secondYear] andStartMonth:startMonth];
        _openYears = _openYears ? [_openYears arrayByAddingObject:openYear] : [NSArray arrayWithObject:openYear];
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

- (void)deleteYearObject:(IAEYear *)year permanent:(BOOL)permanent
{
    NSMutableSet *exceptionObjects = [NSMutableSet setWithArray:self.years];
    [exceptionObjects removeObject:year];
    
    [self doRefreshObjectMergeChangesExceptForObjects:exceptionObjects];
    [self.years removeObject:year];
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
    [self loadYearsNotLoadedYetWithBonduaryYears];
    [self openAllYearsBasedInLoadedYears];
}

- (void)loadYearsNotLoadedYetWithBonduaryYears
{
    [self loadYearsNotLoadedYet];
    [self createBonduaryYears];
    [self loadYearsNotLoadedYet];
}

- (void)loadYearsNotLoadedYet
{
    NSArray *allYearsObjects = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:UINT_MAX andPredicate:nil]];
    for (IAEYear *yearObjectIt in allYearsObjects) {
        if ([_years indexOfObject:yearObjectIt] == NSNotFound) {
            [_years addObject:yearObjectIt];
        }
    }
}

// Nota:
// En caso de que se cambie el mes inicial de Enero es necesario que todo año con conceptos tenga un año previo creado con el fin
// de que se de siempre una combinatoria de años (año-1,año) y (año,año+1) que garantice que el concepto que tenga siempre este presente
// Este metodo se encarga de esto.
// No hay que preocuparse por la memoria. El sistema se encarga de eliminar años sin conceptos.
- (void)createBonduaryYears
{
    NSArray *allYearsLoaded = [_years copy];
    for (IAEYear *yearIt in allYearsLoaded) {
        if ([yearIt findNumberOfConcepts] > 0) {
            NSUInteger previousYearDate = yearIt.yearDate - 1;
            IAEYear *previousYear = [self findYearObjectWithDate:previousYearDate];
            if (!previousYear) {
                [self createYearObjectWithDate:previousYearDate];
            }
        }
    }
}

- (void)openAllYearsBasedInLoadedYears
{
    // Nota:
    // - It's necessary to copy the _years array because the methods that appear here can create new IAEYear objects in the
    // _year array. That was, in fact, the caouse of a bug.
    NSMutableArray *allExistingYearsDates = [[NSMutableArray alloc] initWithCapacity:_years.count];
    NSArray *actualLoadedYears = [NSArray arrayWithArray:_years];
    for (IAEYear *year in actualLoadedYears) {
        [allExistingYearsDates addObject:@(year.yearDate)];
    }
    
    for (NSNumber *yearDate in allExistingYearsDates) {
        [self openYear:yearDate];
    }
}

- (void)saveAndCloseAllAndOpenYearWithDate:(NSNumber *)yearDate
{
    [self saveAll];
    [self closeAllAndOpenYearWithDate:yearDate];
}

- (NSArray *)findOpenYearsDifferentFromYearDate:(NSNumber *)yearDate
{
    NSMutableArray *openYearsToClose = [NSMutableArray arrayWithCapacity:self.openYears.count];
    for (IAEOpenYear *openYearIt in self.openYears) {
        if (openYearIt.yearDate != yearDate.integerValue) {
            [openYearsToClose addObject:@(openYearIt.yearDate)];
        }
    }
    
    return [NSArray arrayWithArray:openYearsToClose];
}

// SOLO PARA EL FIX DE INICIO
- (void)closeAll
{
    self.openYears = [NSArray array];

    while (self.years.count > 0) {
        IAEYear *year = [self.years objectAtIndex:0];
        [self deleteYearObject:year permanent:[year findAllConcepts].count == 0];
    }
}

- (void)closeAllAndOpenYearWithDate:(NSNumber *)yearDate
{
    NSArray *openYearsToClose = [NSArray arrayWithArray:[self findOpenYearsDifferentFromYearDate:yearDate]];
    [self closeOpenYearsWithDates:openYearsToClose];
    [self openYear:yearDate];
}

- (void)closeOpenYearsWithDates:(NSArray *)openYearDatesToClose
{
    NSMutableArray *helperOpenYearDatesToClose = [NSMutableArray arrayWithArray:openYearDatesToClose];
    
    while (helperOpenYearDatesToClose.count > 0) {
        NSNumber *openYearDateToClose = helperOpenYearDatesToClose[0];
        [self closeYearWithYearDate:openYearDateToClose.integerValue];
        [helperOpenYearDatesToClose removeObject:openYearDateToClose];
    }
    
    [self saveAll];
}

- (void)closeYearWithYearDate:(NSUInteger)yearDate
{
    [self removeOpenYearObjectWithoutUnloadYearObjectsWithDate:yearDate];
    
    [self unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:yearDate];
    [self unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:yearDate + 1];
    [self unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:yearDate - 1];
}

- (void)unloadOrDestroyIfNoConceptsOrOpenYearReferencesYearObjectWithDate:(NSUInteger)yearDate
{
    IAEYear *yearObject = [self findYearObjectWithDate:yearDate];
    if (yearObject) {
        NSArray *openYearsWithReferences = [self findOpenYearsObjectsWithReferencesToYearObject:yearObject];
        const BOOL canUnloadOrDestroy = openYearsWithReferences.count == 0;
        if (canUnloadOrDestroy) {
            const NSUInteger numberOfConcepts = [yearObject findNumberOfConcepts];
            const BOOL permanentDelete = 0 == numberOfConcepts;
            [self deleteYearObject:yearObject permanent:permanentDelete];
        }
    }
}

- (void)removeOpenYearObjectWithoutUnloadYearObjectsWithDate:(NSUInteger)yearDate
{
    IAEOpenYear *openYear = [self findOpenYearObjectWithDate:yearDate];
    NSMutableArray *newOpenYears = [NSMutableArray arrayWithArray:self.openYears];
    [newOpenYears removeObject:openYear];
    self.openYears = [NSArray arrayWithArray:newOpenYears];
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

- (NSArray *)findAllOpenYearsWithConceptsSorted
{
    NSArray *years = [self findAllOpenYearsWithConcepts];
    years = [years sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAEOpenYear *openYear1 = obj1;
        IAEOpenYear *openYear2 = obj2;
        return [@(openYear1.yearDate) compare:@(openYear2.yearDate)];
    }];
    
    years = [years.reverseObjectEnumerator allObjects];
    
    return years;
}

- (IAEOpenYear *)findActualOpenYear
{
    // Siempre se considera que el año actualmente abierto es el primero
    // Y es valido que no haya ningun año abierto (se da cuando el año actual NO tiene ningun concepto)
    return self.openYears.count > 0 ? [self.openYears objectAtIndex:0] : nil;
}

@end
