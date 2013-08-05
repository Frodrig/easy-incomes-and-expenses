//
//  IAEHelperCalculatorDataSource.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 31/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEHelperCalculatorDataSource.h"
#import "IAEEasyIncomesAndExpensesViewControllerQuery.h"

@interface IAEHelperCalculatorDataSource()

@property (nonatomic, weak) id<IAEEasyIncomesAndExpensesViewControllerQuery> iaeViewControllerQuery;

@end

@implementation IAEHelperCalculatorDataSource

#pragma mark - Init

- (id)initWithEasyIncomesAndExpensesViewControllerQuery:(id<IAEEasyIncomesAndExpensesViewControllerQuery>)query
{
    self = [super init];
    if (self) {
        _iaeViewControllerQuery = query;
    }
    
    return self;
}

- (id)init
{
    NSAssert(0, @"");
    return nil;
}

#pragma mark - IAECalculatorViewControllerDataSource

- (IAEYear *)yearForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    return [self.iaeViewControllerQuery findOpenYear];
}

- (IAEMonth *)monthForCalculatorViewController:(IAECalculatorViewController *)calculatorViewController
{
    return [self.iaeViewControllerQuery findActualSelectedMonth];
}

@end
