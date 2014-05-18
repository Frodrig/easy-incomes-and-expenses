//
//  SKProduct+FormatedPrice.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "SKProduct+FormatedPrice.h"

@implementation SKProduct (FormatedPrice)

- (NSString *)formattedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    
    return formattedString;
}

@end
