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
#import "IAEDateHelper.h"

@implementation IAEMonth

@dynamic month;
@dynamic concepts;
@dynamic year;

@synthesize delegate = _delegate;

static const NSUInteger kInvalidDayOfTheMonth = 0;

static NSString * const kEntityNameConcept = @"IAEConcept";

static NSString * const kLTextJanuaryName = @"January";
static NSString * const kLTextFebruaryName = @"February";
static NSString * const kLTextMarchName = @"March";
static NSString * const kLTextAprilName = @"April";
static NSString * const kLTextMayName = @"May";
static NSString * const kLTextJuneName = @"June";
static NSString * const kLTextJulyName = @"July";
static NSString * const kLTextAugustName = @"August";
static NSString * const kLTextSeptemberName = @"September";
static NSString * const kLTextOctoberName = @"October";
static NSString * const kLTextNovemberName = @"November";
static NSString * const kLTextDecemberName = @"December";

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

- (IAEConcept *)addConceptWithAmount:(NSDecimalNumber *)amount
                            category:(IAECategory *)category
                                date:(NSTimeInterval)date
                      andDescription:(NSString *)description
{
    return [self addConceptWithAmount:amount
                             category:category
                                 date:date
                        dayOfTheMonth:kInvalidDayOfTheMonth
                       andDescription:description];
}

- (IAEConcept *)addConceptWithAmount:(NSDecimalNumber *)amount
                            category:(IAECategory *)category
                                date:(NSTimeInterval)date
                       dayOfTheMonth:(NSUInteger)dayOfTheMonth
                      andDescription:(NSString *)description
{
    IAEConcept *newConcept = nil;
    if ([amount compare:[NSDecimalNumber zero]] != NSOrderedSame) {
        newConcept = [NSEntityDescription insertNewObjectForEntityForName:kEntityNameConcept inManagedObjectContext:[IAEBook sharedBook].context];
        [self addConceptsObject:newConcept];
        newConcept.category = category;
        newConcept.amount = amount;
        newConcept.date = date;
        newConcept.dayOfTheMonth = dayOfTheMonth;
        newConcept.detailDescription = [description copy];
    }
    
    return newConcept;
}

- (void)removeConcept:(IAEConcept *)concept
{
    [self.delegate month:self willRemoveConcept:concept];
    
    [self removeConceptsObject:concept];
    [[IAEBook sharedBook].context deleteObject:concept];
    
    [self.delegate conceptRemovedFromMonth:self];
}

- (NSDecimalNumber *)sumAllAmountOfCategoryType:(CategoryType)category
{
    NSDecimalNumber *sumDecimalNumber = [NSDecimalNumber zero];
    for (IAEConcept *concept in self.concepts) {
        if (concept.category.categoryType == category) {
            sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:concept.amount];
        }
    }
    
    return sumDecimalNumber;
}

- (NSDecimalNumber *)sumAllAmountOfCategory:(IAECategory *)category
{
    NSDecimalNumber *sumDecimalNumber = [NSDecimalNumber zero];
    for (IAEConcept *concept in self.concepts) {
        if (concept.category == category) {
            sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:concept.amount];
        }
    }
    
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
    for (IAECategory *category in categories) {
        sumDecimalNumber = [sumDecimalNumber decimalNumberByAdding:[self sumAllAmountOfCategory:category]];
    }
    
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
    for (IAECategory *category in categories) {
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

- (NSString *)monthAsString
{
    return [IAEDateHelper findMonthNameStringWithMonthIndex:self.month inShortForm:NO];
    
}
- (NSString *)description
{
    static NSDictionary *monthsNames = nil;
    if (!monthsNames) {
        monthsNames = @{[NSNumber numberWithInt:January]: kLTextJanuaryName,
                                  [NSNumber numberWithInt:February]: kLTextFebruaryName,
                                  [NSNumber numberWithInt:March]: kLTextMarchName,
                                  [NSNumber numberWithInt:April]: kLTextAprilName,
                                  [NSNumber numberWithInt:May]: kLTextMayName,
                                  [NSNumber numberWithInt:June]: kLTextJuneName,
                                  [NSNumber numberWithInt:July]: kLTextJulyName,
                                  [NSNumber numberWithInt:August]: kLTextAugustName,
                                  [NSNumber numberWithInt:September]: kLTextSeptemberName,
                                  [NSNumber numberWithInt:October]: kLTextOctoberName,
                                  [NSNumber numberWithInt:November]: kLTextNovemberName,
                                  [NSNumber numberWithInt:December]: kLTextDecemberName,};
    }
    
    NSString *retDescription = [monthsNames objectForKey:[NSNumber numberWithInt:self.month]];
    retDescription = NSLocalizedString(retDescription, @"");
    NSAssert(retDescription, @"");
    
    return retDescription;
}

@end
