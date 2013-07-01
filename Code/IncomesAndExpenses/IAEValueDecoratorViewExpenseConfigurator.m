//
//  IAEValueDecoratorViewExpenseConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewExpenseConfigurator.h"
#import "IAEValueDecoratorView.h"
#import "IAEColorHelper.h"

@implementation IAEValueDecoratorViewExpenseConfigurator

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [super configure:decoratorView];

    decoratorView.backgroundColor = [IAEColorHelper colorForEconomicExpenseValue];
}

@end
