//
//  IAEValueDecoratorViewIncomeConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewIncomeConfigurator.h"
#import "IAEValueDecoratorView.h"
#import "IAEColorHelper.h"

@implementation IAEValueDecoratorViewIncomeConfigurator

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [super configure:decoratorView];
    
    decoratorView.backgroundColor = [IAEColorHelper colorForEconomicIncomeValue];
}

@end
