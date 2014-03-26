//
//  IAECategoryStore.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 24/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECategoryStore.h"
#import "IAECategory.h"
#import "IAEConcept.h"
#import "IAEBook.h"

@interface IAECategoryStore()

@end

@implementation IAECategoryStore

@synthesize userDefinedCategories = _userDefinedCategories;

static NSString * const kEntityNameCategory = @"IAECategory";
static NSString * const kCategoryPropertyNameTag = @"tag";

#pragma mark - Singleton

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedCategoryStore];
}

+ (IAECategoryStore *)sharedCategoryStore
{
    static IAECategoryStore *sharedCategoryStore = nil;
    if (!sharedCategoryStore) {
        sharedCategoryStore = [[super allocWithZone:nil] init];
    }
    
    return sharedCategoryStore;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        [self createIncomeAndExpenseCategories];
        
        [self setAsObserverOfCategories:@[_generalIncomeCategory]];
        [self setAsObserverOfCategories:@[_generalExpenseCategory]];
        [self setAsObserverOfCategories:[self userDefinedCategories]];
        
        [self sortUserCategoriesByTag];
    }
    
    return self;
}

- (NSMutableArray *)userDefinedCategories
{
    if (!_userDefinedCategories) {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:kEntityNameCategory];
        request.predicate = [NSPredicate predicateWithFormat:@"(NOT tag MATCHES %@) AND (NOT tag MATCHES %@)",
                             tagGeneralIncomeCategory,
                             tagGeneralExpenseCategory];
        
        NSError *error = nil;
        NSArray *fetchRequest = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
        if (error != nil) {
            [NSException raise:@"IAECategoryStore: Failed searching all categories " format:@"cause :%@", error];
        } else {
            _userDefinedCategories = [NSMutableArray arrayWithArray:fetchRequest];
        }
    }
    
    return _userDefinedCategories;
}

- (void)setAsObserverOfCategories:(NSArray *)categories
{
    for (IAECategory *category in categories) {
        [category addObserver:self forKeyPath:kCategoryPropertyNameTag
                      options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
                      context:NULL];
    }
}

- (void)createIncomeAndExpenseCategories
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:@"IAECategory"];
    
    NSError *error;
    NSArray *result = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
    if (!result) {
        [NSException raise:@"IAECategoryStore: Failed fetching" format:@"Cause: %@", error];
    }
    
    if (result.count == 0) {
        // Nota: Las categorias base no se pueden crear por el usuario, ni renombrar ni borrar, por lo que no emiten notificacion
        _generalIncomeCategory = [self createCategoryWithoutChecksAndObserversOfType:IncomeCategory andTag:tagGeneralIncomeCategory];
        _generalExpenseCategory = [self createCategoryWithoutChecksAndObserversOfType:ExpenseCategory andTag:tagGeneralExpenseCategory];
    } else {
        _generalIncomeCategory = [self findCategoryByTag:tagGeneralIncomeCategory];
        _generalExpenseCategory = [self findCategoryByTag:tagGeneralExpenseCategory];
    }
}

- (IAECategory *)createCategoryWithoutChecksAndObserversOfType:(CategoryType)type andTag:(NSString *)tag
{
    IAECategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"IAECategory"
                                                            inManagedObjectContext:[IAEBook sharedBook].context];
    newCategory.categoryType = type;
    newCategory.tag = tag;
    
    return newCategory;
}

- (IAECategory *)createCategoryOfType:(CategoryType)type andTag:(NSString *)tag withValidityTagCheck:(BOOL)validity;
{
    IAECategory *newCategory = nil;
    
    BOOL canCreate = validity ? [IAECategory isAValidTag:[self normalizeCategoryTag:tag]] == ValidTag: YES;
    if (canCreate) {
        newCategory = [self createCategoryWithoutChecksAndObserversOfType:type andTag:[self normalizeCategoryTag:tag]];
        [_userDefinedCategories addObject:newCategory];
        [self sortUserCategoriesByTag];
        [self setAsObserverOfCategories:@[newCategory]];
    }
    
    return newCategory;
}

- (void)removeCategory:(IAECategory *)category
{
    /*
    if (category && category != self.generalIncomeCategory && category != self.generalExpenseCategory) {
        IAECategory *baseCategory = category.categoryType == IncomeCategory ? self.generalIncomeCategory : self.generalExpenseCategory;
        
        NSArray *conceptsWithCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category];
        for (IAEConcept *concept in conceptsWithCategory) {
            concept.category = baseCategory;
        }
        
        [category removeObserver:self forKeyPath:kCategoryPropertyNameTag context:NULL];
        [_userDefinedCategories removeObject:category];
        [[IAEBook sharedBook].context deleteObject:category];
        
        [[IAEBook sharedBook] saveAll];
    }
    
    return;
    */
    if (category && category != self.generalIncomeCategory && category != self.generalExpenseCategory) {
        IAECategory *baseCategory = category.categoryType == IncomeCategory ? self.generalIncomeCategory : self.generalExpenseCategory;
        
        NSArray *allYearsDatesActuallyLoaded = [[IAEBook sharedBook] findAllYeardDatesLoaded];
        [[IAEBook sharedBook] loadAll];
        
        NSArray *conceptsWithCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category];
        for (IAEConcept *concept in conceptsWithCategory) {
            concept.category = baseCategory;
        }

        [category removeObserver:self forKeyPath:kCategoryPropertyNameTag context:NULL];
        [_userDefinedCategories removeObject:category];
        [[IAEBook sharedBook].context deleteObject:category];
        
        [[IAEBook sharedBook] saveAll];
        
        [[IAEBook sharedBook] unloadAllAndLoadYearDates:allYearsDatesActuallyLoaded];
    }
}

- (void)removeCategoryByTag:(NSString *)tag
{
    IAECategory *category = [self findCategoryByTag:tag];
    
    [self removeCategory:category];
    [[IAEBook sharedBook].context deleteObject:category];
}

- (NSArray *)allUserCategoriesOfType:(CategoryType)type
{
    NSMutableArray *retCategories = [NSMutableArray arrayWithCapacity:self.userDefinedCategories.count];
    for (IAECategory *category in self.userDefinedCategories) {
        if (category.categoryType == type) {
            [retCategories addObject:category];
        }
    }
    
    return retCategories;
}

- (NSArray *)generalCategoryAndAllUserCategoriesOfType:(CategoryType)type
{
    NSArray *allUserCategories = [self allUserCategoriesOfType:type];
    NSArray *generalCategory = [NSArray arrayWithObject:type == IncomeCategory ? [self generalIncomeCategory] : [self generalExpenseCategory]];
    NSArray *retArray = [generalCategory arrayByAddingObjectsFromArray:allUserCategories];
    
    return retArray;
}

// Nota: Como los tags son key y tambien texto para UI, tenemos que comprobar si se ha seleccionado uno generico o no para usar su valor key
- (NSString *)normalizeCategoryTag:(NSString *)tag
{
    NSString *retNormalizedTag = tag;
    if ([tag compare:NSLocalizedString(tagGeneralIncomeCategory, tagGeneralIncomeCategory)] == NSOrderedSame) {
        retNormalizedTag = tagGeneralIncomeCategory;
    } else if ([tag compare:NSLocalizedString(tagGeneralExpenseCategory, tagGeneralExpenseCategory)] == NSOrderedSame) {
        retNormalizedTag = tagGeneralExpenseCategory;
    }
    
    return retNormalizedTag;
}

- (void)sortUserCategoriesByTag
{
    [self.userDefinedCategories sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAECategory *category1 = obj1;
        IAECategory *category2 = obj2;
        NSComparisonResult result = [category1.tag caseInsensitiveCompare:category2.tag];
        
        return result;
    }];
}

- (BOOL)isGeneralCategory:(IAECategory *)category
{
    return [self generalExpenseCategory] == category || [self generalIncomeCategory] == category;
}

- (IAECategory *)findCategoryByTag:(NSString *)tag
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:kEntityNameCategory];
    request.predicate = [NSPredicate predicateWithFormat:@"tag like %@", [self normalizeCategoryTag:tag]];
    
    NSError *error = nil;
    NSArray *requestResult = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
    if (error != nil) {
        [NSException raise:@"IAECategoryStore: Failed searching category" format:@"cause :%@", error];
    }
    
    return requestResult.count > 0 ? [requestResult objectAtIndex:0] : nil;
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{    
    if ([keyPath isEqualToString:kCategoryPropertyNameTag]) {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        if ([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting && newValue != [NSNull null]) {
            // Se ha producido un rename
            // Nota: En caso de que se asigne el mismo string pero diferenciado en mayusculas y minusculas manda evento
            NSString *strOldValue = oldValue;
            NSString *strNewValue = newValue;
             if (![strOldValue isEqualToString:strNewValue]) {
                [self sortUserCategoriesByTag];
            }
        }
    }
}


@end
