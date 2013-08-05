//
//  IAEValueDecoratorViewConfigurator.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEValueDecoratorView;

@interface IAEValueDecoratorViewConfigurator : NSObject

+ (instancetype)valueDecoratorViewConfiguratorForIncomeValue;
+ (instancetype)valueDecoratorViewConfiguratorForExpenseValue;
+ (instancetype)valueDecoratorViewConfiguratorForInvalidValue;

- (void)configure:(IAEValueDecoratorView *)decoratorView;
   
@end
