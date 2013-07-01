//
//  IAEValueDecoratorViewConfigurator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorViewConfigurator.h"
#import "IAEValueDecoratorViewInvalidConfigurator.h"
#import "IAEValueDecoratorViewExpenseConfigurator.h"
#import "IAEValueDecoratorViewIncomeConfigurator.h"
#import "UIView+RoundedCorners.h"
#import "IAEValueDecoratorView.h"

@implementation IAEValueDecoratorViewConfigurator

+ (instancetype)valueDecoratorViewConfiguratorForIncomeValue
{
    return (IAEValueDecoratorViewConfigurator *)[[IAEValueDecoratorViewIncomeConfigurator alloc] init];
}

+ (instancetype)valueDecoratorViewConfiguratorForExpenseValue
{
    return (IAEValueDecoratorViewConfigurator *)[[IAEValueDecoratorViewExpenseConfigurator alloc] init];
}

+ (instancetype)valueDecoratorViewConfiguratorForInvalidValue
{
    return (IAEValueDecoratorViewConfigurator *)[[IAEValueDecoratorViewInvalidConfigurator alloc] init];
}

- (void)configure:(IAEValueDecoratorView *)decoratorView
{
    [decoratorView addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0];
}

@end
