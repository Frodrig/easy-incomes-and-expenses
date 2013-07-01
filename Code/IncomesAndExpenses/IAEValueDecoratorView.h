//
//  IAEValueDecoratorView.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IAEValueDefs.h"

@interface IAEValueDecoratorView : UIView

@property(nonatomic, readwrite) EconomicValueType economicValueType;

+ (instancetype)valueDecoratorViewOfIncomeValueType;
+ (instancetype)valueDecoratorViewOfExpenseValueType;
+ (instancetype)valueDecoratorViewOfInvalidValueType;

@end
