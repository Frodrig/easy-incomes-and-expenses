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

- (NSArray *)ordererMonths
{
    if (nil == ordererMonths_) {
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
    IAEMonth *newMonth = [NSEntityDescription insertNewObjectForEntityForName:@"IAEMonth"
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
    
    if (result ==  NSOrderedAscending)
        result = NSOrderedDescending;
    else if (result == NSOrderedDescending)
        result = NSOrderedAscending;
    
    return result;
}

- (NSDecimalNumber *)expenses
{
    NSDecimalNumber *sumExpenses = [NSDecimalNumber zero];
    
    for (IAEMonth *month in self.months)
        sumExpenses = [sumExpenses decimalNumberByAdding:month.expenses];
    
    return sumExpenses;
}

- (NSDecimalNumber *)incomes
{
    NSDecimalNumber *sumIncomes = [NSDecimalNumber zero];
    
    for (IAEMonth *month in self.months)
        sumIncomes = [sumIncomes decimalNumberByAdding:month.incomes];
    
    return sumIncomes;
}

- (NSDecimalNumber *)balance
{
    NSDecimalNumber *sumBalance = [NSDecimalNumber zero];
    
    for (IAEMonth *month in self.months)
        sumBalance = [sumBalance decimalNumberByAdding:month.balance];
    
    return sumBalance;
}

- (NSArray *)findAllConceptsWithCategory:(IAECategory *)category
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.months.count];
    for (IAEMonth *month in self.months)
        [concepts addObjectsFromArray:[month findAllConceptsWithCategory:category]];
    
    return concepts;
}

- (NSArray *)findAllConcepts
{
    NSMutableArray *concepts = [[NSMutableArray alloc] initWithCapacity:self.months.count];
    for (IAEMonth *months in self.months) {
        NSArray *conceptsOfMonth = [months.concepts sortedArrayUsingDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO]]];
        [concepts addObjectsFromArray:conceptsOfMonth];
    }
    
    return concepts;
}

- (NSUInteger)findNumberOfConcepts
{
    return [self findAllConcepts].count;
}


@end
