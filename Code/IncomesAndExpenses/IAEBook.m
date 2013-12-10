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
    
    NSURL *storeURL = [self storeFileURLWithPath];
    
    NSError *error;
    if (![persistentStore addPersistentStoreWithType:NSSQLiteStoreType
                                       configuration:nil
                                                 URL:storeURL
                                             options:nil
                                               error:&error]) {
        [NSException raise:@"Open DB failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    if (![[NSFileManager defaultManager] setAttributes:@{NSFileProtectionKey: NSFileProtectionComplete}
                                          ofItemAtPath:storeURL.path
                                                 error:&error]) {
        [NSException raise:@"Set protection attribute failed" format:@"Reason: %@", [error localizedDescription]];
    }
    
    _context = [[NSManagedObjectContext alloc] init];
    _context.persistentStoreCoordinator = persistentStore;
    _context.undoManager = nil;
}

- (void)prepareYearContainers
{
    _years = [NSMutableArray array];
    _openYears = [NSArray array];
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
    if (nil != error) {
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
