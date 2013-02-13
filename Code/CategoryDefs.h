//
//  CategoryDefs.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 24/10/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#ifndef IncomesAndExpenses_CategoryDefs_h
#define IncomesAndExpenses_CategoryDefs_h

typedef enum
{
    IncomeCategory = 0,
    ExpenseCategory,
    InvalidCategory
} CategoryType;

typedef enum
{
    InvalidEmptyTag = 0,
    InvalidWhiteSpaceOnlyTag,
    InvalidEqualToAnotherTag,
    ValidTag
} ValidTagCheckResult;

#endif
