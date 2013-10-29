//
//  IAEOpenYear.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 28/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEOpenYear.h"

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
    
    // ...
}

#pragma mark - Balances

- (NSDecimalNumber *)expenses
{
    return nil;
}

- (NSDecimalNumber *)incomes
{
    return nil;
}

- (NSDecimalNumber *)balance
{
    return nil;
}

- (NSDecimalNumber *)balanceOfAllConceptsOfCategory:(IAECategory *)category
{
    return nil;
}

#pragma mark - SearchMode

- (void)beginCategoryConceptSearchMode
{
}

- (void)endCategoryConceptSearchMode
{
}

#pragma mark - Find

- (NSArray *)findAllOrdererMonthsWithConcepts
{
    return nil;
}

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    return nil;
}

- (NSArray *)findAllConcepts
{
    return nil;
}

- (NSArray *)findAllConceptsSortedByEntryInstant
{
    return nil;
}

- (NSArray *)findAllConceptsSortedByDay
{
    return nil;
}

- (NSArray *)findAllCategoriesSortedByAbsoluteValueOfAmountsInConceptsOfType:(CategoryType)type
{
    return nil;
}

- (NSUInteger)findNumberOfConcepts
{
    return 0;
}

#pragma mark - String

- (NSString *)yearDateAsString
{
    return nil;
}


@end
