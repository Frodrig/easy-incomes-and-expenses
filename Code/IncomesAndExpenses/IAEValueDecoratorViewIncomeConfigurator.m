//
//  IAEValueDecoratorViewIncomeConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewIncomeConfigurator.h"
#import "IAEValueDecoratorView.h"

@implementation IAEValueDecoratorViewIncomeConfigurator

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [super configure:decoratorView];
    
    decoratorView.backgroundColor = [UIColor colorWithRed:120.0/255.0 green:191.0/255.0 blue:175.0/255.0 alpha:1.0];
}

@end
