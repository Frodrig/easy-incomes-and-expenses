//
//  IAEOpenYear.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEOpenYear.h"
#import "IAEYear.h"
#import "IAEMonth.h"

#define DISABLE_PERFORM_SELECTOR_WARNING \
_Pragma("clang diagnostic push");\
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"");

#define ENABLE_PERFORM_SELECTOR_WARNING \
_Pragma("clang diagnostic pop");

@interface IAEOpenYear()

@property (nonatomic) NSInteger yearDate;
@property (nonatomic, strong) NSArray *years;
@property (nonatomic, strong) NSArray *months;

@end

@implementation IAEOpenYear

#pragma mark - Init

- (instancetype)initWithYears:(NSArray *)years andStartMonth:(MonthType)startMonth
{
    self = [super init];
    if (self) {
        [self setYears:years andStartMonth:startMonth];
    }
    
    return self;
}

- (void)setYears:(NSArray *)years andStartMonth:(MonthType)startMonth
{
    NSAssert(startMonth != InvalidMonth, @"");
    NSAssert((startMonth == January && years.count == 1) || (startMonth > January && years.count == 2) , @"");
    
    _years = [years copy];
    _months = [self createMonthsWithYears:years andStartMonth:startMonth];
}

- (NSArray *)createMonthsWithYears:(NSArray *)years andStartMonth:(MonthType)startMonth
{
    NSMutableArray *ordererMonths = [[NSMutableArray alloc] initWithCapacity:kMonthsPerYear];
    MonthType startMonthForIteration = startMonth;
    for (IAEYear *year in years) {
        for (MonthType monthIt = startMonthForIteration; monthIt != InvalidMonth || ordererMonths.count < kMonthsPerYear ; ++monthIt) {
            NSUInteger monthIndex = monthIt - 1;
            IAEMonth *month = [year.ordererMonths objectAtIndex:monthIndex];
            [ordererMonths addObject:month];
        }
        
        if (ordererMonths.count != kMonthsPerYear) {
            NSAssert(years.count == 2, @"Si no se ha llenado el array de meses con doce meses es que la vista tiene dos años involucrados");
            startMonthForIteration = January;
        }
    }
    
    NSArray *retMonths = [NSArray arrayWithArray:ordererMonths];
    return retMonths;
}

#pragma mark - Balances

- (NSDecimalNumber *)expenses
{
    NSDecimalNumber *result = [self decimalNumberOperationInMonthsWithSelector:@selector(expenses) andObject:nil];
    
    return result;
}

- (NSDecimalNumber *)incomes
{
    NSDecimalNumber *result = [self decimalNumberOperationInMonthsWithSelector:@selector(incomes) andObject:nil];
    
    return result;
}

- (NSDecimalNumber *)balance
{
    NSDecimalNumber *result = [self decimalNumberOperationInMonthsWithSelector:@selector(balance) andObject:nil];
    
    return result;
}

- (NSDecimalNumber *)decimalNumberOperationInMonthsWithSelector:(SEL)theSelector andObject:(id)object
{
    NSDecimalNumber *decimalNumberResult = [NSDecimalNumber zero];
    for (IAEMonth *month in self.months) {
        DISABLE_PERFORM_SELECTOR_WARNING;
        NSDecimalNumber *actualValue = object ? [month performSelector:theSelector withObject:object] : [month performSelector:theSelector];
        ENABLE_PERFORM_SELECTOR_WARNING
        decimalNumberResult = [decimalNumberResult decimalNumberByAdding:actualValue];
    }
    
    return decimalNumberResult;
}

- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category
{
    NSDecimalNumber *result = [self decimalNumberOperationInMonthsWithSelector:@selector(balanceOfAllConceptsOfCategory:) andObject:category];
    
    return result;
}

#pragma mark - SearchMode

- (void)beginCategoryConceptSearchMode
{
    [self.months makeObjectsPerformSelector:@selector(beginCategoryConceptSearchMode)];
}

- (void)endCategoryConceptSearchMode
{
    [self.months makeObjectsPerformSelector:@selector(endCategoryConceptSearchMode)];
}

#pragma mark - Find

- (NSArray *)findAllOrdererMonthsWithConcepts
{
    NSMutableArray *monthsWithConcepts = [[NSMutableArray alloc] initWithCapacity:kMonthsPerYear];
    for (IAEMonth *month in self.months) {
        if (month.concepts.count > 0) {
            [monthsWithConcepts addObject:month];
        }
    }
    
    NSArray *resultMonths = [[NSArray alloc] initWithArray:monthsWithConcepts];
    return resultMonths;
}

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *conceptsWithCategory = [[NSMutableArray alloc] initWithCapacity:kMonthsPerYear];
    for (IAEMonth *month in self.months) {
        NSArray *conceptsWithCategoryInMonth = [month findAllConceptsWithCategory:category];
        [conceptsWithCategory addObjectsFromArray:conceptsWithCategoryInMonth];
    }
    
    NSArray *resultConcepts = [[NSArray alloc] initWithArray:conceptsWithCategory];
    return resultConcepts;
}

- (NSArray *)findAllConcepts
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.months.count];
    for (IAEMonth *months in self.months) {
        NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
        NSArray *conceptsOfMonth = [months.concepts sortedArrayUsingDescriptors:@[sortDescriptor]];
        [concepts addObjectsFromArray:conceptsOfMonth];
    }
    
    NSArray *resultConcepts = [[NSArray alloc] initWithArray:concepts];
    return resultConcepts;
}

- (NSArray *)findAllConceptsSortedByEntryInstant
{
    NSArray *allConceptSorted = [self findOperationInMonthsWithSelector:@selector(allConceptsSortedByEntryInstant)];
    
    return allConceptSorted;
}

- (NSArray *)findAllConceptsSortedByDay
{
    NSArray *allConceptSorted = [self findOperationInMonthsWithSelector:@selector(allConceptsSortedByDay)];
    
    return allConceptSorted;
}

- (NSArray *)findOperationInMonthsWithSelector:(SEL)findSelector
{
    NSArray *allConceptSorted = [NSArray array];
    for (IAEMonth *month in self.months) {
        DISABLE_PERFORM_SELECTOR_WARNING;
        NSArray *allConceptsSortedInMonth = [month performSelector:findSelector];
        ENABLE_PERFORM_SELECTOR_WARNING;
        allConceptSorted = [allConceptSorted arrayByAddingObjectsFromArray:allConceptsSortedInMonth];
    }
    
    return allConceptSorted;
}

- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type
{
    NSArray *allCategories = [NSArray array];
    for (IAEMonth *months in self.months) {
        NSArray *allCategoriesOfMonth = [months findAllCategoriesInConceptsOfType:type];
        allCategories = [allCategories arrayByAddingObjectsFromArray:allCategoriesOfMonth];
    }
    
    allCategories = [allCategories sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        IAECategory *category1 = obj1;
        IAECategory *category2 = obj2;
        NSDecimalNumber *amountCategory1 = [self balanceOfAllConceptsOfCategory:category1];
        NSDecimalNumber *amountCategory2 = [self balanceOfAllConceptsOfCategory:category2];
        NSComparisonResult compareResult = [amountCategory2 compare:amountCategory1];
        
        return compareResult;
    }];
    
    
    return allCategories;
}

- (NSUInteger)findNumberOfConcepts
{
    NSArray *concepts = [self findAllConcepts];
    NSUInteger numberOfConcepts = concepts.count;
    
    return numberOfConcepts;
}

#pragma mark - String

- (NSString *)yearDateAsString
{
    NSAssert(self.years.count == 1 || self.years.count == 2, @"");
    NSString *resultString = nil;
    if (self.years.count == 1) {
        resultString = [NSString stringWithFormat:@"%d", self.yearDate];
    } else {
        resultString = [NSString stringWithFormat:@"%d - %d", self.yearDate, self.yearDate + 1];
    }
    
    return resultString;
}


@end
