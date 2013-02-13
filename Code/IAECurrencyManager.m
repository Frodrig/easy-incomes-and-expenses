//
//  IAECurrencyManager.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAECurrencyManager.h"
#import "IAECurrencyInfo.h"

@implementation IAECurrencyManager

//@synthesize currencies = currencies_;
@synthesize currencyFormatter = currencyFormatter_;

- (NSNumberFormatter *)currencyFormatter
{
    if (nil == currencyFormatter_) {
        currencyFormatter_ = [[NSNumberFormatter alloc] init];
       [currencyFormatter_ setNumberStyle:NSNumberFormatterCurrencyStyle];
        currencyFormatter_.locale = [NSLocale currentLocale];
        currencyFormatter_.minimumFractionDigits = 2;
        currencyFormatter_.maximumFractionDigits = 2;
        currencyFormatter_.maximumFractionDigits = 2;
        currencyFormatter_.generatesDecimalNumbers = YES;
    }
    
    return currencyFormatter_;
}

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
    if (self)
    {
        //[self createCurrencies];
        
        //[self setInitialCurrencyCodeOfUser];
        
        //[self initCurrencyFormatter];
    }
    
    return self;
}
/*
- (NSString *)findSymbolForCurrencyCode:(NSString *)currencyCode
{
    // Iteraremos por los locales y si hay alguno que usa como moneda el currencyCode pasado tomaremos el simbolo
    NSString *retSymbol;
    
    NSArray *locales = [NSLocale availableLocaleIdentifiers];
    for (NSString *localeIt in locales)
    {
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:localeIt];
        
        if ([[locale objectForKey:NSLocaleCurrencyCode] isEqualToString:currencyCode])
        {
            retSymbol = [locale objectForKey:NSLocaleCurrencySymbol];
            
            break;
        }
    }
    
    return retSymbol;
}

- (NSString *)findDescriptionForCurrencyCode:(NSString *)currencyCode
{
    return @"Description";
}

- (void)createCurrencies
{
    NSArray *commonCurrencyCodes = [NSLocale commonISOCurrencyCodes];
    
    currencies_ = [NSMutableArray arrayWithCapacity:commonCurrencyCodes.count];
    
    for (NSString *strCurrencyCode in commonCurrencyCodes)
    {
        NSString *currencySymbol = [self findSymbolForCurrencyCode:strCurrencyCode];
        NSString *currencyDescription = [self findDescriptionForCurrencyCode:strCurrencyCode];
        
        IAECurrencyInfo *currency = [[IAECurrencyInfo alloc] initWithCode:strCurrencyCode symbol:currencySymbol andDescription:currencyDescription];
        
        [currencies_ addObject:currency];
    }
}

- (void)setInitialCurrencyCodeOfUser
{
    NSString *actualCodeCurrency = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserCodeCurrency"];
    if (nil == actualCodeCurrency)
    {
        NSLocale *locale = [NSLocale currentLocale];
        
        IAECurrencyInfo *currencyInfoOfLocale = [self currencyInfoOfCurrencyCode:[locale objectForKey:NSLocaleCurrencyCode]];
        
        [[NSUserDefaults standardUserDefaults] setObject:currencyInfoOfLocale != nil ? currencyInfoOfLocale.code : @"USD" forKey:@"UserCodeCurrency"];
    }
}

- (IAECurrencyInfo *)currencyInfoOfCurrencyCode:(NSString *)code
{
    IAECurrencyInfo *retCurrencyInfo;
    
    NSUInteger indexOfCurrencyInfo = [self.currencies indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        IAECurrencyInfo *currencyInfo = obj;
        
        *stop = [currencyInfo.code isEqualToString:code];
        
        return *stop;
    }];
    
    if (indexOfCurrencyInfo != NSNotFound)
        retCurrencyInfo = [self.currencies objectAtIndex:indexOfCurrencyInfo];
    
    return retCurrencyInfo;
}

- (void)setUserCurrencyCode:(IAECurrencyInfo *)currency
{
    if (currency)
    {
        [[NSUserDefaults standardUserDefaults] setObject:currency.code forKey:@"UserCodeCurrency"];
    }
}

- (IAECurrencyInfo *)findUserCurrencyInfo
{
    NSString *currencyCode = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserCodeCurrency"];
    
    IAECurrencyInfo *currencyInfo = [self currencyInfoOfCurrencyCode:currencyCode];
    
    return currencyInfo;
}
*/

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

@end
