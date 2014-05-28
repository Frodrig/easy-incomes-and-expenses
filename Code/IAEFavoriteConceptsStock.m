//
//  IAEFavoriteConceptsStock.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 03/01/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEFavoriteConceptsStock.h"
#import "IAECategory.h"
#import "IAEConcept.h"

static NSString * const kFavoriteConceptsFile = @"favorite_concepts.data";

@interface IAEFavoriteConceptsStock()

@property (nonatomic, strong) NSMutableDictionary *favorites;

@end

@implementation IAEFavoriteConceptsStock

+ (IAEFavoriteConceptsStock *)sharedInstance
{
    static IAEFavoriteConceptsStock *sharedStock = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedStock = [[self alloc] init];
    });
    
    return sharedStock;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self load];
    }
    
    return self;
}

- (void)load
{
    NSString *pathToFile = [self makePathForFavoriteConceptsFile];
    //[[NSFileManager defaultManager] removeItemAtPath:pathToFile error:NULL];
    const BOOL fileExist = [[NSFileManager defaultManager] fileExistsAtPath:pathToFile];
    _favorites = fileExist ? [NSMutableDictionary dictionaryWithContentsOfFile:pathToFile] : [NSMutableDictionary new];
}

- (NSString *)makePathForFavoriteConceptsFile
{
    NSArray *documentDirectories = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = documentDirectories[0];
    NSString *path = [documentDirectory stringByAppendingPathComponent:kFavoriteConceptsFile];
    
    return path;
}

- (void)addFavorite:(IAEConcept *)concept
{
    //NSAssert(![self isMarkedAsFavorite:concept], @"");
    if (![self isMarkedAsFavorite:concept]) {
        NSString *categoryTag = [concept.category localizedTag];
        NSMutableArray *valuesForCategory = [self.favorites valueForKey:categoryTag];
        if (!valuesForCategory) {
            self.favorites[categoryTag] = [NSMutableArray arrayWithObject:[concept.amount stringValue]];
        } else {
            [valuesForCategory addObject:[concept.amount stringValue]];
        }
    }
}

- (void)removeAndSaveFavoriteWithCategory:(NSString *)category andValue:(NSString *)value
{
    [self removeFavoriteWithCategory:category andValue:value];
    [self save];
}

- (void)removeAndSaveFavoriteOfConcept:(IAEConcept *)concept
{
    [self removeFavoriteOfConcept:concept];
    [self save];
}

- (void)removeAndSaveFavoriteWithCategory:(NSString *)category
{
    [self removeFavoriteWithCategory:category];
    [self save];
}

- (void)removeFavoriteWithCategory:(NSString *)category andValue:(NSString *)value
{
    NSMutableArray *valuesOfCategory = [self.favorites valueForKey:category];
    if (valuesOfCategory) {
        const NSUInteger indexOfValue = [self findIndexOfvalue:value inCategoryValues:valuesOfCategory];
        if (indexOfValue != NSNotFound) {
            [valuesOfCategory removeObjectAtIndex:indexOfValue];
            if (valuesOfCategory.count == 0) {
                [self.favorites removeObjectForKey:category];
            }
        }
    }
}

- (NSUInteger)findIndexOfvalue:(NSString *)value inCategoryValues:(NSArray *)values
{
    const NSUInteger indexOfValue = [values indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        NSString *valueIt = obj;
        *stop = [valueIt isEqualToString:value];
        return *stop;
    }];
    
    return indexOfValue;
}

- (void)removeFavoriteOfConcept:(IAEConcept *)concept
{
    NSString *categoryString = [concept.category localizedTag];
    NSString *valueString = [concept.amount stringValue];
    
    [self removeFavoriteWithCategory:categoryString andValue:valueString];
}

- (void)removeFavoriteWithCategory:(NSString *)category
{
    [self.favorites removeObjectForKey:category];
}

- (BOOL)isMarkedAsFavorite:(IAEConcept *)concept
{
    BOOL isMarked = NO;
    
    NSMutableArray *valuesForCategory = [self.favorites valueForKey:[concept.category localizedTag]];
    if (valuesForCategory) {
        NSString *valueStringToFind = [concept.amount stringValue];
        const NSUInteger indexOfValue = [self findIndexOfvalue:valueStringToFind inCategoryValues:valuesForCategory];
        isMarked = indexOfValue != NSNotFound;
    }
    
    return isMarked;
}

- (void)removeAll
{
    self.favorites = [NSMutableDictionary new];
}

- (void)save
{
    NSString *pathToFile = [self makePathForFavoriteConceptsFile];
    [self.favorites writeToFile:pathToFile atomically:YES];
}

- (void)reload
{
    [self load];
}


@end
