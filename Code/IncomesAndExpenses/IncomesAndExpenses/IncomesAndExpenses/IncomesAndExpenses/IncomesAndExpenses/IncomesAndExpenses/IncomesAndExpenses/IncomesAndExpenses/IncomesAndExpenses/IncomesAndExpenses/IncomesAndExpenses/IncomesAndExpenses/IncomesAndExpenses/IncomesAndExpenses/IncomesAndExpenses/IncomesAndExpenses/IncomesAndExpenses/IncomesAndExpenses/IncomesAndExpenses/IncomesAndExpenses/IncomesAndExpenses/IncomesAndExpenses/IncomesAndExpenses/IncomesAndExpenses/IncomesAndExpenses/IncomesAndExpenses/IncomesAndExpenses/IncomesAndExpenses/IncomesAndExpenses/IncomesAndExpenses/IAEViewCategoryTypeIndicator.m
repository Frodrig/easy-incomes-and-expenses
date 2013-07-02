//
//  IAEViewCategoryTypeIndicator.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 15/01/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEViewCategoryTypeIndicator.h"
#include "IAEViewUtils.h"
#include "IAEConstants.h"

@interface IAEViewCategoryTypeIndicator()

@property(nonatomic) BOOL roundedCornesApplied;

@end

@implementation IAEViewCategoryTypeIndicator

@synthesize category = category_;
@synthesize roundedCornesApplied = roundedCornersApplied_;

- (void)setCategory:(CategoryType)category
{
    self.backgroundColor = category == IncomeCategory ? [IAEConstants incomeValueColor] : [IAEConstants expenseValueColor];
    
    category_ = category;
}

- (void)applyRoundedCorners
{
    if (!self.roundedCornesApplied)
    {
        [IAEViewUtils addRoundedCorners:UIRectCornerTopLeft | UIRectCornerBottomLeft withRadius:10.0 toView:self];
       
        self.roundedCornesApplied = YES;
    }
}

@end
