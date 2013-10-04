//
//  IAECurrencyManager.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECurrencyManager.h"
#import "IAECurrencyInfo.h"

@interface IAECurrencyManager()

@end

@implementation IAECurrencyManager

+ (IAECurrencyManager *)sharedManager
{
    static IAECurrencyManager *manager = nil;
    if (!manager)
        manager = [[super allocWithZone:nil] init];
    
    return manager;
}

- (id)allocWithZone:(NSZone *)zone
{
    return [IAECurrencyManager sharedManager];
}

- (id)init
{
    self = [super init];
    if (self) {
    }
    
    return self;
}

- (NSString *)decimalSeparator
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey:NSLocaleDecimalSeparator];
}

- (NSString *)groupingSeparator
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey:NSLocaleGroupingSeparator];
}

- (NSString *)currencySymbol
{
    NSLocale *locale = [NSLocale currentLocale];
    return [locale objectForKey:NSLocaleCurrencySymbol];
}

@end
