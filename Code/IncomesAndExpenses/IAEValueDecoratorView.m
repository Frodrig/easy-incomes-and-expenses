//
//  IAEValueDecoratorView.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEValueDecoratorView.h"
#import "IAEValueDecoratorViewConfigurator.h"

@implementation IAEValueDecoratorView

- (void)setEconomicValueType:(EconomicValueType)economicValueType
{
    if (economicValueType != _economicValueType) {
        _economicValueType = economicValueType;
        [self configureAspectBasedInValueType];
    }
}

+ (instancetype)valueDecoratorViewOfIncomeValueType
{
    return [self valueDecoratorOfValueType:ECONOMIC_INCOME_VALUE];
}

+ (instancetype)valueDecoratorViewOfExpenseValueType
{
    return [self valueDecoratorOfValueType:ECONOMIC_EXPENSE_VALUE];
}

+ (instancetype)valueDecoratorViewOfZeroValueType
{
    return [self valueDecoratorOfValueType:ECONOMIC_ZERO_VALUE];
}

+ (instancetype)valueDecoratorOfValueType:(EconomicValueType)valueType
{
    IAEValueDecoratorView *decoratorView = [[IAEValueDecoratorView alloc] init];
    decoratorView.economicValueType = valueType;
    
    return decoratorView;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configureAtInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self configureAtInit];
    }
    
    return self;
}

- (void)configureAtInit
{
    _economicValueType = ECONOMIC_ZERO_VALUE;
    [self configureAspectBasedInValueType];
}

- (void)configureAspectBasedInValueType
{
    IAEValueDecoratorViewConfigurator *decoratorViewConfigurator = nil;
    switch (self.economicValueType) {
        case ECONOMIC_INCOME_VALUE:
            decoratorViewConfigurator = [IAEValueDecoratorViewConfigurator valueDecoratorViewConfiguratorForIncomeValue];
            break;
        case ECONOMIC_EXPENSE_VALUE:
            decoratorViewConfigurator = [IAEValueDecoratorViewConfigurator valueDecoratorViewConfiguratorForExpenseValue];
            break;
        default:
            NSAssert(self.economicValueType == ECONOMIC_ZERO_VALUE, @"Tipo de valor desconocido");
            decoratorViewConfigurator = [IAEValueDecoratorViewConfigurator valueDecoratorViewConfiguratorForInvalidValue];
            break;
    };
    
    [decoratorViewConfigurator configure:self];
}


@end
