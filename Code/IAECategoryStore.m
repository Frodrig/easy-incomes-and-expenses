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

@implementation IAECategoryStore

@synthesize userDefinedCategories = _userDefinedCategories;

- (NSMutableArray *)userDefinedCategories
{
    if (_userDefinedCategories == nil)
    {
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:@"IAECategory"];
        request.predicate = [NSPredicate predicateWithFormat:@"(NOT tag MATCHES %@) AND (NOT tag MATCHES %@)", @"General Income", @"General Expense"];
        
        NSError *error;
        
        NSArray *fetchRequest = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
        if (error != nil)
            [NSException raise:@"IAECategoryStore: Failed searching all categories " format:@"cause :%@", error];
        else
            _userDefinedCategories = [NSMutableArray arrayWithArray:fetchRequest];
    }
    
    return _userDefinedCategories;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [self sharedCategoryStore];
}

+ (IAECategoryStore *)sharedCategoryStore
{
    static IAECategoryStore *sharedCategoryStore = nil;
    if (!sharedCategoryStore)
        sharedCategoryStore = [[super allocWithZone:nil] init];
    
    return sharedCategoryStore;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        // Prepara las categorias iniciales si la base de datos esta vacia
        [self createIncomeAndExpenseCategories];
        
        // Se añade como observer de las categorias ya existentes
        [self setAsObserverOfCategories:[NSArray arrayWithObject:[self generalIncomeCategory]]];
        [self setAsObserverOfCategories:[NSArray arrayWithObject:[self generalExpenseCategory]]];
        [self setAsObserverOfCategories:[self userDefinedCategories]];
        
        [self sortUserCategoriesByTag];
    }
    
    return self;
}

- (void)setAsObserverOfCategories:(NSArray *)categories
{
    /*
    [categories enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        IAECategory *category = obj;
        
        [category addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }];
     */
    for (IAECategory *category in categories)
    {
        [category addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];
    }
}

- (void)createIncomeAndExpenseCategories
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:@"IAECategory"];
    
    NSError *error;
    NSArray *result = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
    if (nil != error)
    {
        [NSException raise:@"IAECategoryStore: Failed fetching" format:@"Cause: %@", error];
    }
    
    if (result.count == 0)
    {
        // Nota: Las categorias base no se pueden crear por el usuario ni renombrar ni borrar por lo que no emiten notificacion
        [self createCategoryWithoutChecksAndObserversOfType:IncomeCategory andTag:@"General Income"];
        [self createCategoryWithoutChecksAndObserversOfType:ExpenseCategory andTag:@"General Expense"];
    }
}

- (IAECategory *)createCategoryWithoutChecksAndObserversOfType:(CategoryType)type andTag:(NSString *)tag
{
    IAECategory *newCategory = [NSEntityDescription insertNewObjectForEntityForName:@"IAECategory" inManagedObjectContext:[IAEBook sharedBook].context];
    
    newCategory.categoryType = type;
    newCategory.tag = tag;
    
    return newCategory;
}

- (IAECategory *)createCategoryOfType:(CategoryType)type andTag:(NSString *)tag withValidityTagCheck:(BOOL)validity;
{
    IAECategory *newCategory;

    BOOL canCreate = validity ? [IAECategory isAValidTag:[self normalizeCategoryTag:tag]] == ValidTag: YES;
    
    if (canCreate)
    {
        newCategory = [self createCategoryWithoutChecksAndObserversOfType:type andTag:[self normalizeCategoryTag:tag]];
        
        [_userDefinedCategories addObject:newCategory];
        
        [self sortUserCategoriesByTag];
    
        [newCategory addObserver:self forKeyPath:@"tag" options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:NULL];

        NSDictionary *extraInfo = [NSDictionary dictionaryWithObject:newCategory forKey:@"Category"];
        NSNotification *notification = [NSNotification notificationWithName:@"CategoryCreated" object:self userInfo:extraInfo];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return newCategory;
}

- (void)removeCategory:(IAECategory *)category
{
    if (category && category != self.generalIncomeCategory && category != self.generalExpenseCategory)
    {
        IAECategory *baseCategory = category.categoryType == IncomeCategory ? self.generalIncomeCategory : self.generalExpenseCategory;
        
        NSArray *conceptsWithCategory = [[IAEBook sharedBook] findAllConceptsWithCategory:category];
        for (IAEConcept *concept in conceptsWithCategory)
        {
            concept.category = baseCategory;
        }
        
        NSDictionary *extraInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSNumber numberWithInt:category.categoryType], category.tag, nil]
                                                              forKeys:[NSArray arrayWithObjects:@"CategoryType", @"CategoryTag", nil]];
        NSNotification *notification = [NSNotification notificationWithName:@"CategoryRemoved" object:self userInfo:extraInfo];
        
        [category removeObserver:self forKeyPath:@"tag" context:NULL];
        
        [_userDefinedCategories removeObject:category];
        
        [[IAEBook sharedBook].context deleteObject:category];
        
        [[NSNotificationCenter defaultCenter] postNotification:notification];
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
    
    for (IAECategory *category in self.userDefinedCategories)
        if (category.categoryType == type)
            [retCategories addObject:category];
    
    return retCategories;
}

- (NSArray *)generalCategoryAndAllUserCategoriesOfType:(CategoryType)type
{
    NSArray *allUserCategories = [self allUserCategoriesOfType:type];
    NSArray *generalCategory = [NSArray arrayWithObject:type == IncomeCategory ? [self generalIncomeCategory] : [self generalExpenseCategory]];
    NSArray *retArray = [generalCategory arrayByAddingObjectsFromArray:allUserCategories];
    
    return retArray;
}

// Como los tags son key y tambien texto para UI tenemos que comprobar si se ha seleccionado uno generico o no para usar su valor key
- (NSString *)normalizeCategoryTag:(NSString *)tag
{
    NSString *retNormalizedTag = tag;
    if ([tag compare:NSLocalizedString(@"General Income", @"General Income")] == NSOrderedSame) {
        retNormalizedTag = @"General Income";
    } else if ([tag compare:NSLocalizedString(@"General Expense", @"General Expense")] == NSOrderedSame) {
        retNormalizedTag = @"General Expense";
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

- (IAECategory *)generalIncomeCategory
{
    return [self findCategoryByTag:@"General Income"];
}

- (IAECategory *)generalExpenseCategory
{
    return [self findCategoryByTag:@"General Expense"];
}

- (BOOL)isGeneralCategory:(IAECategory *)category
{
    return [self generalExpenseCategory] == category || [self generalIncomeCategory] == category;
}

- (IAECategory *)findCategoryByTag:(NSString *)tag
{
    NSString *normalizedTag = [self normalizeCategoryTag:tag];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.entity = [[[IAEBook sharedBook].model entitiesByName] objectForKey:@"IAECategory"];
    request.predicate = [NSPredicate predicateWithFormat:@"tag like %@", normalizedTag];
    
    NSError *error;
    NSArray *requestResult = [[IAEBook sharedBook].context executeFetchRequest:request error:&error];
    if (error != nil)
    {
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
    if ([keyPath isEqualToString:@"tag"])
    {
        id oldValue = [change objectForKey:NSKeyValueChangeOldKey];
        id newValue = [change objectForKey:NSKeyValueChangeNewKey];
        
        if ([[change objectForKey:NSKeyValueChangeKindKey] intValue] == NSKeyValueChangeSetting && newValue != [NSNull null])
        {
            NSString *strOldValue = oldValue;
            NSString *strNewValue = newValue;
            
            // Se ha producido un rename
            // Nota: En caso de que se asigne el mismo string pero diferenciado en mayusculas y minusculas manda evento
             if (![strOldValue isEqualToString:strNewValue])
            {
                // Ordenamos
                [self sortUserCategoriesByTag];
                
                NSDictionary *extraInfo = [NSDictionary
                                           dictionaryWithObjects:[NSArray arrayWithObjects:object, strOldValue, nil]
                                           forKeys:[NSArray arrayWithObjects:@"Category", @"OldTag", nil]];
                
                NSNotification *notification = [NSNotification notificationWithName:@"CategoryRenamed" object:self userInfo:extraInfo];
                
                [[NSNotificationCenter defaultCenter] postNotification:notification];
            }
        }
    }
    
    // Nota: No hay que pasar a super observeValueForKeyPath... ya que es NSObject y no lo implementa
    
}


@end
