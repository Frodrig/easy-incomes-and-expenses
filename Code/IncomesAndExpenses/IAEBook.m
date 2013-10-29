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
    }
    
    return self;
}

- (NSURL *)storeFileURLWithPath
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [documentDirectories objectAtIndex:0];
    NSURL* retURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:kFileNameForStoreData]];
    
    return retURL;
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

- (void)closeAll
{
    [self unloadAll];
}

- (void)unloadAll
{    
    [self doRefreshObjectMergeChangesExceptForObjects:nil];
    [self releaseYears];
}

- (void)releaseYears
{
    _openYears = nil;
    _years = nil;
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
    if (nil != error) {
        [NSException raise:@"Fetch failed loading years" format:@"Reason: %@", [error localizedDescription]];
    }
    
    return yearsLoaded;
}

- (void)openAll
{
    [self loadAll];
}

- (void)loadAll
{
    [self doRefreshObjectMergeChangesExceptForObjects:[NSSet setWithArray:self.years]];

    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:UINT_MAX andPredicate:nil]];
    _openYears = [self createOpenYearsArrayFromYearsLoaded];
}

- (NSArray *)createOpenYearsArrayFromYearsLoaded
{
    NSMutableArray *openYears = [[NSMutableArray alloc] initWithCapacity:_years.count];
    for (IAEYear *year in _years) {
        IAEOpenYear *openYear = [[IAEOpenYear alloc] initWithYears:@[year] andStartMonth:January];
        [openYears addObject:openYear];
    }
    
    NSArray *resultOpenYears = [NSArray arrayWithArray:openYears];
    return resultOpenYears;
}

- (void)loadYear:(NSUInteger)year
{
    IAEYear *yearFound;
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
    
    _openYears = [self createOpenYearsArrayFromYearsLoaded];
}

- (void)openMoreRecientYear
{
    [self loadMoreRecientYear];
}

- (void)loadMoreRecientYear
{
    [self doRefreshObjectMergeChangesExceptForObjects:nil];
    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:nil]];
    _openYears = [self createOpenYearsArrayFromYearsLoaded];
}

- (IAEOpenYear *)closeAllAndOpenYear:(NSNumber *)yearDate
{
    [self unloadAll];
    [self loadYear:yearDate.integerValue];
    if (![self findYearWithDate:yearDate]) {
        [self createYear:yearDate];
        _openYears = [self createOpenYearsArrayFromYearsLoaded];
    }
    
    IAEOpenYear *openYear = [self findActualOpenYear];
    return openYear;
}

- (IAEOpenYear *)openYear:(NSNumber *)yearDate
{
    IAEOpenYear *yearOpened = [self findOpenYearWithDate:yearDate];
    if (!yearOpened) {
        IAEYear *newYear = [NSEntityDescription insertNewObjectForEntityForName:@"IAEYear" inManagedObjectContext:self.context];
        newYear.yearDate = yearDate.intValue;
        
        yearOpened = [[IAEOpenYear alloc] initWithYears:@[newYear] andStartMonth:January];
        
        [self.years addObject:newYear];
        [self.years sortUsingSelector:@selector(compareDescendingPriority:)];
        self.openYears = [self.openYears arrayByAddingObject:yearOpened];
        self.openYears = [self.openYears sortedArrayUsingSelector:@selector(compareDescendingPriority:)];
    }
    
    return yearOpened;
}


- (void)createYear:(NSNumber *)yearDate
{
    IAEYear *newYear = nil;
    if (![self findYearWithDate:yearDate]) {
        newYear = [NSEntityDescription insertNewObjectForEntityForName:@"IAEYear" inManagedObjectContext:self.context];
        newYear.yearDate = yearDate.intValue;
        
        [self.years addObject:newYear];
        [self.years sortUsingSelector:@selector(compareDescendingPriority:)];
     }
}

- (void)deleteYear:(NSNumber *)yearDate
{
    IAEYear *year = [self findYearWithDate:yearDate];
    [self deleteYearObject:year];
}

- (IAEYear *)findYearWithDate:(NSNumber *)yearDate
{
    NSAssert(yearDate.unsignedIntegerValue, @"");
    
    IAEYear *resultYear = nil;
    for (IAEYear *year in self.years) {
        if (year.yearDate == yearDate.unsignedIntegerValue) {
            resultYear = year;
            break;
        }
    }
    
    return resultYear;
}

- (void)deleteYearObject:(IAEYear *)year
{
    if (year) {
        [self updateOpenYearsWithoutYear:year];
        [self.years removeObjectIdenticalTo:year];
        [self.context deleteObject:year];
    }
}

- (void)updateOpenYearsWithoutYear:(IAEYear *)year
{
    NSAssert(year, @"");
    
    IAEOpenYear *openYear = [self findOpenYearWithDate:@(year.yearDate)];
    NSAssert(openYear, @"");
    NSMutableArray *updatedOpenYears = [NSMutableArray arrayWithArray:self.openYears];
    [updatedOpenYears removeObject:openYear];
    self.openYears = [NSArray arrayWithArray:updatedOpenYears];
}

- (void)deleteAllConceptsOfOpenYear:(IAEOpenYear *)year
{
    [year deleteAllConcepts];
    [self saveAll];
}

/*
- (void)deleteAllConceptsOfYear:(IAEYear *)year
{
    if ([year findNumberOfConcepts] > 0) {
        NSNumber *yearDate = [NSNumber numberWithUnsignedInteger:year.yearDate];
        [self deleteYear:yearDate];
        [self createYear:yearDate];
    }
}
*/
- (void)postYearRemovedNotificationWithYearDate:(NSUInteger)yearDate
{
    NSArray *objectsForExtraInfoDictionary = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:yearDate], nil];
    NSArray *keysForExtraInfoDictionary = [NSArray arrayWithObjects:@"YearDate", nil];
    NSDictionary *extraInfo = [NSDictionary dictionaryWithObjects:objectsForExtraInfoDictionary forKeys:keysForExtraInfoDictionary];
    NSNotification *notification = [NSNotification notificationWithName:@"YearRemoved" object:self userInfo:extraInfo];
    
    [[NSNotificationCenter defaultCenter] postNotification:notification];
}

- (void)closeAllOpenYearsPreservingActualYear
{
    IAEOpenYear *actualOpenYear = [self findActualOpenYear];
    NSAssert(actualOpenYear, @"");
    NSMutableSet *yearsToClose = [[NSMutableSet alloc] initWithCapacity:self.years.count];
    for (IAEYear *year in self.years) {
        if ([actualOpenYear.years indexOfObject:year] == NSNotFound) {
            [yearsToClose addObject:year];
        }
    }
    
    while (yearsToClose.count > 0) {
        IAEYear *year = [yearsToClose anyObject];
        [yearsToClose removeObject:year];
        [self.years removeObjectIdenticalTo:year];
    }
    
    _openYears = [NSArray arrayWithObject:actualOpenYear];
}

// Nota: Preserva siempre el año actual aunque no tenga conceptos
/*
- (void)deleteYearsWithZeroConceptsPreservingActualYear
{
    IAEYear *actualYear = [self findActualYear];
    if (actualYear) {
        NSMutableArray *actualLoadedYears = [NSMutableArray arrayWithArray:self.years];
        
        [self loadAll];

        NSMutableSet *yearsToDelete = [[NSMutableSet alloc] initWithCapacity:self.years.count];
        for (IAEYear *year in self.years) {
            if ([year findNumberOfConcepts] == 0 && actualYear != year) {
                [yearsToDelete addObject:year];
            }
        }
        
        while (yearsToDelete.count > 0) {
            IAEYear *yearObjectToDelete = [yearsToDelete anyObject];
            [yearsToDelete removeObject:yearObjectToDelete];
            
            [actualLoadedYears removeObjectIdenticalTo:yearObjectToDelete];
            [self deleteYearObject:yearObjectToDelete];
        }
        
        if (actualLoadedYears.count > 0) {
            _years = [NSMutableArray arrayWithArray:actualLoadedYears];
        }
    }
}
*/
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
    _openYears = nil;
    [self loadAll];
    
    while (self.years.count > 0) {
        IAEYear *year = [self.years objectAtIndex:0];
        [self deleteYear:[NSNumber numberWithUnsignedInteger:year.yearDate]];
    }
    
    NSAssert(self.years.count == 0, @"");
    [self saveAll];
    
    _openYears = [NSArray array];
}

#pragma mark - Find

/*
- (IAEYear *)findActualYear
{
    // Cuando estamos fuera de la pantalla de seleccion de año solo hay un año cargado y es el primero del array
    NSAssert(self.years.count == 1, @"O no hay años o bien hay mas de uno cargado");
    return [self.years objectAtIndex:0];
}

- (NSArray *)findAllYearWithConcepts
{
    NSMutableArray *yearsSelected = [NSMutableArray arrayWithCapacity:self.years.count];
    for (IAEYear *year in self.years) {
        if ([year findNumberOfConcepts] > 0) {
            [yearsSelected addObject:year];
        }
    }
    
    return [NSArray arrayWithArray:yearsSelected];
}

// Nota: Solo para los años cargados
- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.years.count];
    for (IAEYear *year in self.years) {
        [concepts addObjectsFromArray:[year findAllConceptsWithCategory:category]];
    }
    
    return concepts;
}

- (IAEYear *)findYearWithDate:(NSNumber *)yearDate
{
    NSAssert(yearDate.unsignedIntegerValue, @"");
    
    IAEYear *resultYear = nil;
    for (IAEYear *year in self.years) {
        if (year.yearDate == yearDate.unsignedIntegerValue) {
            resultYear = year;
            break;
        }
    }
    
    if (!resultYear) {
        NSArray *result = [self loadYearsWithLimit:1 andPredicate:[NSPredicate predicateWithFormat:@"yearDate == %d", yearDate.unsignedIntegerValue]];
        if (result.count > 0) {
            resultYear = [result objectAtIndex:0];
        }
    }
    
    return resultYear;
}
*/

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

- (IAEOpenYear *)findActualOpenYear
{
    // Cuando estamos fuera de la pantalla de seleccion de año solo hay un año cargado y es el primero del array
    NSAssert(self.openYears.count == 1, @"O no hay años o bien hay mas de uno cargado");
    return [self.openYears objectAtIndex:0];

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

@end
