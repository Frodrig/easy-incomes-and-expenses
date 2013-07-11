//
//  IAECurrencyInfo.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECurrencyInfo.h"

@implementation IAECurrencyInfo

@synthesize code = code_;
@synthesize description = description_;
@synthesize symbol = symbol_;

- (id)init
{
    self = [self initWithCode:nil symbol:nil andDescription:nil];
    
    return self;
}

- (id)initWithCode:(NSString *)code symbol:(NSString *)symbol andDescription:(NSString *)description
{
    self = [super init];
    if (self)
    {
        code_ = code;
        symbol_ = symbol;
        description_ = description;
    }
    
    return self;
}

@end
