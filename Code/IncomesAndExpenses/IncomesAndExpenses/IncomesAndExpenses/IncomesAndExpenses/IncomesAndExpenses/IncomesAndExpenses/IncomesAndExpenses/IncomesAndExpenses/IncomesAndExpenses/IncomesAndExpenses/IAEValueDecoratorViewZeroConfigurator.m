//
//  IAEValueDecoratorViewInvalidConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewZeroConfigurator.h"
#import "IAEValueDecoratorView.h"
#import "IAEColorHelper.h"

@implementation IAEValueDecoratorViewZeroConfigurator

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [super configure:decoratorView];
    
    decoratorView.backgroundColor = [IAEColorHelper colorForEconomicInvalidValue];
}

@end
