//
//  IAEYear.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 26/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEYear.h"
#import "IAEMonth.h"
#import "IAEBook.h"


@implementation IAEYear

@dynamic yearDate;
@dynamic months;

@synthesize ordererMonths = ordererMonths_;

static NSString * const kEntityNameMonth = @"IAEMonth";

- (NSArray *)ordererMonths
{
    if (!ordererMonths_) {
        ordererMonths_ = [self.months sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"month" ascending:YES]]];
    }
    
    return ordererMonths_;
}

- (void)awakeFromInsert
{
    [super awakeFromInsert];
    [self createAndAddAllMonthsForFirstTime];
}

- (void)dealloc
{
    self.ordererMonths = nil;
}

- (void)createAndAddAllMonthsForFirstTime
{
    NSSet *setOfMonths = [NSSet setWithObjects: [self createMonthInDB:January],
                                                [self createMonthInDB:February],
                                                [self createMonthInDB:March],
                                                [self createMonthInDB:April],
                                                [self createMonthInDB:May],
                                                [self createMonthInDB:June],
                                                [self createMonthInDB:July],
                                                [self createMonthInDB:August],
                                                [self createMonthInDB:September],
                                                [self createMonthInDB:October],
                                                [self createMonthInDB:November],
                                                [self createMonthInDB:December],
                                                nil];
    
    [self addMonths:setOfMonths];
}

- (IAEMonth *)createMonthInDB:(MonthType)month
{
    IAEMonth *newMonth = [NSEntityDescription insertNewObjectForEntityForName:kEntityNameMonth
                                                       inManagedObjectContext:[IAEBook sharedBook].context];
    newMonth.month = month;
   
    return newMonth;
}

- (NSComparisonResult)compare:(IAEYear *)aYear
{
    NSNumber *yearDateNumber = [NSNumber numberWithInt:self.yearDate];
    
    return [yearDateNumber compare:[NSNumber numberWithInt:aYear.yearDate]];
}

- (NSComparisonResult)compareDescendingPriority:(IAEYear *)aYear
{
    NSComparisonResult result = [self compare:aYear];
    if (result ==  NSOrderedAscending) {
        result = NSOrderedDescending;
    } else if (result == NSOrderedDescending) {
        result = NSOrderedAscending;
    }
    
    return result;
}

- (NSDecimalNumber *)expenses
{
    NSDecimalNumber *sumExpenses = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        sumExpenses = [sumExpenses decimalNumberByAdding:month.expenses];
    }
    
    return sumExpenses;
}

- (NSDecimalNumber *)incomes
{
    NSDecimalNumber *sumIncomes = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        sumIncomes = [sumIncomes decimalNumberByAdding:month.incomes];
    }
    
    return sumIncomes;
}

- (NSDecimalNumber *)balance
{
    NSDecimalNumber *sumBalance = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        sumBalance = [sumBalance decimalNumberByAdding:month.balance];
    }
    
    return sumBalance;
}

- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category
{
    NSDecimalNumber *sumBalance = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        sumBalance = [sumBalance decimalNumberByAdding:[month balanceOfAllConceptsOfCategory:category]];
    }
    
    return sumBalance;
}

- (NSDecimalNumber *)sumAllAmountOfCategories:(NSArray *)categories
{
    NSDecimalNumber *sumBalance = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        sumBalance = [sumBalance decimalNumberByAdding:[month sumAllAmountOfCategories:categories]];
    }
    
    return sumBalance;
}

- (void)beginCategoryConceptSearchMode
{
    for (IAEMonth *month in self.months) {
        [month beginCategoryConceptSearchMode];
    }
}

- (void)endCategoryConceptSearchMode
{
    for (IAEMonth *month in self.months) {
        [month endCategoryConceptSearchMode];
    }
}

- (NSArray *)findAllOrdererMonthsWithConcepts
{
    NSMutableArray *ordererMonths = [[NSMutableArray alloc] initWithCapacity:self.ordererMonths.count];
    for (IAEMonth *month in self.ordererMonths) {
        if (month.concepts.count > 0) {
            [ordererMonths addObject:month];
        }
    }
    
    return [NSArray arrayWithArray:ordererMonths];
}


- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.months.count];
    for (IAEMonth *month in self.months) {
        [concepts addObjectsFromArray:[month findAllConceptsWithCategory:category]];
    }
    
    return concepts;
}

- (NSArray *)findAllConcepts
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.months.count];
    for (IAEMonth *months in self.months) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSArray *conceptsOfMonth = [months.concepts sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
        [concepts addObjectsFromArray:conceptsOfMonth];
    }
    
    return [[NSArray alloc] initWithArray:concepts];
}

- (NSUInteger)findNumberOfConcepts
{
    return [self findAllConcepts].count;
}

- (NSArray *)findAllConceptsSortedByEntryInstant
{
    NSArray *allConceptsSorted = [NSArray array];
    for (IAEMonth *month in self.ordererMonths) {
        allConceptsSorted = [allConceptsSorted arrayByAddingObjectsFromArray:[month allConceptsSortedByEntryInstant]];
    }
    
    return allConceptsSorted;
}

- (NSArray *)findAllConceptsSortedByDay
{
    NSArray *allConceptSorted = [NSArray array];
    for (IAEMonth *month in self.ordererMonths) {
        allConceptSorted = [allConceptSorted arrayByAddingObjectsFromArray:[month allConceptsSortedByDay]];
    }
    
    return allConceptSorted;
}

- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type
{
    NSSet *allCategories = [NSSet set];
    for (IAEMonth *months in self.months) {
        NSArray *allCategoriesOfMonth = [months findAllCategoriesInConceptsOfType:type];
        allCategories = [allCategories setByAddingObjectsFromArray:allCategoriesOfMonth];
    }
    
    NSArray *allCategoriesSorted = [allCategories allObjects];
    allCategoriesSorted = [allCategoriesSorted sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAECategory *category1 = obj1;
        IAECategory *category2 = obj2;
        NSDecimalNumber *amountCategory1 = [self balanceOfAllConceptsOfCategory:category1];
        NSDecimalNumber *amountCategory2 = [self balanceOfAllConceptsOfCategory:category2];
        NSComparisonResult compareResult = [amountCategory2 compare:amountCategory1];
        
        return compareResult;
    }];

    
    return allCategoriesSorted;
}

- (NSString *)yearDateAsString
{
    return [NSString stringWithFormat:@"%d", self.yearDate];
}


@end
