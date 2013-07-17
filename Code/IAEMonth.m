//
//  IAEMonth.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMonth.h"
#import "IAEConcept.h"
#import "IAEYear.h"
#import "IAECategory.h"
#import "IAECategoryStore.h"
#import "IAEBook.h"

@implementation IAEMonth

@dynamic month;
@dynamic concepts;
@dynamic year;

@synthesize delegate = _delegate;

/*
+ (id)monthFromYear:(IAEYear *)year withMonthType:(MonthType)month
{
    return [[IAEMonth alloc] initFromYear:year andMonthType:month];
}
*/

- (NSNumber *)daysOfTheMonth
{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.year = self.year.yearDate;
    dateComponents.month = self.month;
        
    NSCalendar *currentCalendar = [NSCalendar currentCalendar];
        
    NSRange daysRange = [currentCalendar rangeOfUnit:NSDayCalendarUnit
                                                  inUnit:NSMonthCalendarUnit
                                                 forDate:[currentCalendar dateFromComponents:dateComponents]];
        
    return [NSNumber numberWithInteger:daysRange.length];
}

- (IAEConcept *)addConceptWithAmount:(NSDecimalNumber *)amount category:(IAECategory *)category date:(NSTimeInterval)date andDescription:(NSString *)description
{
    IAEConcept *newConcept;
    
    if ([amount compare:[NSDecimalNumber zero]] != NSOrderedSame) {
        newConcept = [NSEntityDescription insertNewObjectForEntityForName:@"IAEConcept" inManagedObjectContext:[IAEBook sharedBook].context];
        [self addConceptsObject:newConcept];
 
        [newConcept addObserver:self forKeyPath:@"amount" options:0 context:NULL];
        [newConcept addObserver:self forKeyPath:@"category" options:0 context:NULL];
        [newConcept addObserver:self forKeyPath:@"detailDescription" options:0 context:NULL];
        [newConcept addObserver:self forKeyPath:@"dayOfTheMonth" options:0 context:NULL];

        newConcept.category = category;
        newConcept.amount = amount;
        newConcept.date = date;
        newConcept.detailDescription = [description copy];
        
         NSDictionary *extraInfo = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:self, newConcept, nil] forKeys:[NSArray arrayWithObjects:@"Month", @"Concept", nil]];
         
         NSNotification *notification = [NSNotification notificationWithName:@"NewConceptAdded" object:self userInfo:extraInfo];
         
         [[NSNotificationCenter defaultCenter] postNotification:notification];
    }
    
    return newConcept;
}

- (void)removeConcept:(IAEConcept *)concept
{
    if ([self.delegate respondsToSelector:@selector(month:willRemoveConcept:)])
        [self.delegate month:self willRemoveConcept:concept];
    
    [self removeConceptsObject:concept];
    [[IAEBook sharedBook].context deleteObject:concept];
    
    if ([self.delegate respondsToSelector:@selector(conceptRemovedFromMonth:)])
        [self.delegate conceptRemovedFromMonth:self];
}

- (NSDecimalNumber *)sumAllAmountOfCategoryType:(CategoryType)category
{
    NSDecimalNumber *sumDecimalNumber = [NSDecimalNumber zero];
    
    for (IAEConcept *concept in self.concepts)
        if (concept.category.categoryType == category)
            sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:concept.amount];
    
    return sumDecimalNumber;
}

- (NSDecimalNumber *)sumAllAmountOfCategory:(IAECategory *)category
{
    NSDecimalNumber *sumDecimalNumber = [NSDecimalNumber zero];
    
    for (IAEConcept *concept in self.concepts)
        if (concept.category == category)
            sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:concept.amount];
    
    return sumDecimalNumber;
}

- (NSDecimalNumber *)expenses
{
    return [self sumAllAmountOfCategoryType:ExpenseCategory];
}

- (NSDecimalNumber *)incomes
{
    return [self sumAllAmountOfCategoryType:IncomeCategory];
}

- (NSDecimalNumber *)sumAllAmountOfCategories:(NSArray *)categories
{
    NSDecimalNumber *sumDecimalNumber = [NSDecimalNumber zero];
    
    for (IAECategory *category in categories)
        sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:[self sumAllAmountOfCategory:category]];
    
    return sumDecimalNumber;
}

- (NSDecimalNumber *)balance
{
    NSDecimalNumber *incomes = [self incomes];
    NSDecimalNumber *expenses = [self expenses];
    
    NSDecimalNumber *balance = [incomes decimalNumberBySubtracting:expenses];
    
    return balance;
}

- (NSDecimalNumber *)total
{
    NSDecimalNumber *incomes = [self incomes];
    NSDecimalNumber *expenses = [self expenses];
    
    NSDecimalNumber *total = [incomes decimalNumberByAdding:expenses];
    
    return total;
}

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.concepts.count];
    for (IAEConcept *concept in self.concepts) {
        if (concept.category == category) {
            [concepts addObject:concept];
        }
    }
    
    return concepts;
}

- (NSArray *)findAllConceptsWithCategoryTag:(NSString *)tag
{
    IAECategory *category = [[IAECategoryStore sharedCategoryStore] findCategoryByTag:tag];
    
    return [self findAllConceptsWithCategory:category];
}

- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type
{
    NSArray *categories = [self findAllCategoriesInConceptsOfType:type];
    
    NSMutableDictionary *categoriesAmounts = [[NSMutableDictionary alloc] init];
    for (IAECategory *category in categories)
    {
        NSDecimalNumber *value = [self balanceOfAllConceptsOfCategory:category];
        NSString *key = category.tag;
            
        [categoriesAmounts setObject:value forKey:key];
    }
        
    NSArray *sortedCategories = [categories sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAECategory *category1 = obj1;
        IAECategory *category2 = obj2;
            
        NSDecimalNumber *amountCategory1 = [categoriesAmounts objectForKey:category1.tag];
        NSDecimalNumber *amountCategory2 = [categoriesAmounts objectForKey:category2.tag];
            
        NSComparisonResult compareResult = [amountCategory2 compare:amountCategory1];
            
        return compareResult;
    }];
        
    return sortedCategories;
}

- (NSArray *)findAllCategoriesInConceptsOfType:(CategoryType)type
{
    NSMutableSet *categoriesFound = [NSMutableSet setWithCapacity:self.concepts.count];
    
    NSMutableArray *array = [[NSMutableArray alloc] initWithCapacity:self.concepts.count];
    for (IAEConcept *concept in self.concepts) {
        if (concept.category.categoryType == type && ![categoriesFound containsObject:concept.category]) {
            [array addObject:concept.category];
            [categoriesFound addObject:concept.category];
        }
    }
    
    return array;
}

- (NSArray *)allConceptsSortedByEntryInstant
{
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    return [self allConceptsSortedByDescriptors:@[sortDescriptor]];
}

- (NSArray *)allConceptsSortedByDay
{
    NSSortDescriptor *daySortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"dayOfTheMonth" ascending:NO];
    NSSortDescriptor *dateSortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];

    return [self allConceptsSortedByDescriptors:@[daySortDescriptor, dateSortDescriptor]];
}

- (NSArray *)allConceptsSortedByDescriptors:(NSArray *)sortDescriptors
{
    NSArray *conceptsSorted = [self.concepts sortedArrayUsingDescriptors:sortDescriptors];
    return conceptsSorted;
}

- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category
{
    NSDecimalNumber *balance = [NSDecimalNumber zero];
    NSArray *concepts = [self findAllConceptsWithCategory:category];
    
    for (IAEConcept *concept in concepts) {
        balance = [balance decimalNumberByAdding:concept.amount];
    }
    
    return balance;
}

- (NSString *)description
{
    NSString *retDescription;
    
    switch (self.month) {
        case January:
            retDescription = NSLocalizedString(@"January", @"Enero");
            break;
            
        case February:
            retDescription = NSLocalizedString(@"February", @"Febrero");
            break;
            
        case March:
            retDescription = NSLocalizedString(@"March", @"Marzo");
            break;
            
        case April:
            retDescription = NSLocalizedString(@"April", @"Abril");
            break;
            
        case May:
            retDescription = NSLocalizedString(@"May", @"Mayo");
            break;
            
        case June:
            retDescription = NSLocalizedString(@"June", @"Junio");
            break;
            
        case July:
            retDescription = NSLocalizedString(@"July", @"Julio");
            break;
            
        case August:
            retDescription = NSLocalizedString(@"August", @"Agosto");
            break;
            
        case September:
            retDescription = NSLocalizedString(@"September", @"Septiembre");
            break;
            
        case October:
            retDescription = NSLocalizedString(@"October", @"Octubre");
            break;
            
        case November:
            retDescription = NSLocalizedString(@"November", @"Noviembre");
            break;
            
        case December:
            retDescription = NSLocalizedString(@"December", @"Diciembre");
            break;
            
        default:
            retDescription = @"Invalid";
            break;
    }
    
    return retDescription;
}

#pragma mark - Key-Value Observing

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"dayOfTheMonth"])
    {
        // Habria que reordenar el array
    }
        
    // OJO esto hay que cambiarlo para usar el notification center
    if ([self.delegate respondsToSelector:@selector(month:didUpdateConcept:)])
        [self.delegate month:self didUpdateConcept:object];
}

@end
