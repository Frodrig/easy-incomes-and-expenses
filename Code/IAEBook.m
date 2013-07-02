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

@implementation IAEBook

@synthesize years = _years;
@synthesize context = _context;
@synthesize model = _model;

#pragma mark - Class Singleton

+ (IAEBook *)sharedBook
{
    static IAEBook *sharedBook = nil;
    if (!sharedBook)
        sharedBook = [[super allocWithZone:nil] init];
    
    return sharedBook;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedBook];
}

#pragma mark - Instance

- (id) init
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
    
    NSURL* retURL = [NSURL fileURLWithPath:[documentDirectory stringByAppendingPathComponent:@"incomeandexpenses.data"]];
    
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
                                               error:&error])
    {
        [NSException raise:@"Open DB failed"
                    format:@"Reason: %@", [error localizedDescription]];
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

- (void)unloadAll
{    
    [self doRefreshObjectMergeChangesExceptForObjects:nil];
    
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

- (void)loadAll
{
    [self doRefreshObjectMergeChangesExceptForObjects:[NSSet setWithArray:self.years]];

    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:UINT_MAX andPredicate:nil]];
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
    }
    else {
        [self doRefreshObjectMergeChangesExceptForObjects:nil];
        _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:[NSPredicate predicateWithFormat:@"yearDate == %@", [NSNumber numberWithUnsignedInteger:year]]]];
    }
}

- (void)loadMoreRecientYear
{
    [self doRefreshObjectMergeChangesExceptForObjects:nil];

    _years = [NSMutableArray arrayWithArray:[self loadYearsWithLimit:1 andPredicate:nil]];
}

- (IAEYear *)existYearDate:(NSNumber *)yearDate
{
    IAEYear *resultYear;
    for (IAEYear *year in self.years) {
        if (year.yearDate == yearDate.unsignedIntegerValue) {
            resultYear = year;
            break;
        }
    }
    
    if (!resultYear) {
        NSArray *result = [self loadYearsWithLimit:1 andPredicate:[NSPredicate predicateWithFormat:@"yearDate == %@", [NSNumber numberWithUnsignedInteger:yearDate.unsignedIntegerValue]]];
        if (result.count > 0) {
            resultYear = [result objectAtIndex:0];
        }
    }
    
    return resultYear;
}

- (IAEYear *)createYear:(NSNumber *)yearDate
{
    IAEYear *newYear;
    if (![self existYearDate:yearDate])
    {
        newYear = [NSEntityDescription insertNewObjectForEntityForName:@"IAEYear" inManagedObjectContext:self.context];
        newYear.yearDate = yearDate.intValue;
        
        [self.years addObject:newYear];
        [self.years sortUsingSelector:@selector(compareDescendingPriority:)];
        
        NSDictionary *extraInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:yearDate.unsignedIntValue], nil] forKeys:[NSArray arrayWithObjects:@"YearDate", nil]];
        
        NSNotification *notification = [NSNotification notificationWithName:@"NewYearCreated" object:self userInfo:extraInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
     }
    
    return newYear;
}

- (void)deleteYear:(NSNumber *)yearDate
{
    IAEYear *year = [self existYearDate:yearDate];
    if (year)
    {
        //[self.context deleteObject:year];
        [self.years removeObjectIdenticalTo:year];
        [self.context deleteObject:year];
        
        NSDictionary *extraInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:yearDate.unsignedIntValue], nil] forKeys:[NSArray arrayWithObjects:@"YearDate", nil]];
        
        NSNotification *notification = [NSNotification notificationWithName:@"YearRemoved" object:self userInfo:extraInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];

    }
}

// OJO para los años cargados solo
- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.years.count];
    for (IAEYear *year in self.years) {
        [concepts addObjectsFromArray:[year findAllConceptsWithCategory:category]];
    }
    
    return concepts;
}

- (BOOL)saveAll
{
    NSError *error;
    BOOL saveResult = [self.context save:&error];
    
    if (!saveResult)
        [NSException raise:@"Error saving" format:@"Reason %@", [error localizedDescription]];
    
    return saveResult;
}

- (IAEYear *)findActualYear
{
    // Cuando estamos fuera de la pantalla de seleccion de año solo hay un año cargado y es el primero del array
    NSAssert(self.years.count == 1, @"O no hay años o bien hay mas de uno cargado");
    return [self.years objectAtIndex:0];
}

- (NSUInteger)findTodayMonthIndex
{
    NSDate *today = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *monthComponents = [gregorian components:NSMonthCalendarUnit fromDate:today];
    
    return [monthComponents month] - 1;
}


@end
