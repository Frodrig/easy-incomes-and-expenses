//
//  IAEValueDecoratorViewInvalidConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewInvalidConfigurator.h"
#import "IAEValueDecoratorView.h"

@implementation IAEValueDecoratorViewInvalidConfigurator

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [super configure:decoratorView];
    
    decoratorView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.25];
}

@end
