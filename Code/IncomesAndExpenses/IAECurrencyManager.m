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

@property (nonatomic, strong) NSNumber *maximumFractionDigitState;
@property (nonatomic, strong) NSNumber *minimumFractionDigitState;

@end

@implementation IAECurrencyManager

//@synthesize currencies = currencies_;
@synthesize currencyFormatter = currencyFormatter_;

- (NSNumberFormatter *)currencyFormatter
{
    if (!currencyFormatter_) {
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

- (void)saveCurrencyFormatterFractionState
{
    NSAssert(!self.maximumFractionDigitState && !self.minimumFractionDigitState, @"");
    
    self.maximumFractionDigitState = [NSNumber numberWithUnsignedInteger:self.currencyFormatter.maximumFractionDigits];
    self.minimumFractionDigitState = [NSNumber numberWithUnsignedInteger:self.currencyFormatter.minimumFractionDigits];
}

- (void)restoreCurrencyFormatterFractionState
{
    NSAssert(self.maximumFractionDigitState && self.minimumFractionDigitState, @"");

    self.currencyFormatter.maximumFractionDigits = [self.maximumFractionDigitState unsignedIntegerValue];
    self.currencyFormatter.minimumFractionDigits = [self.minimumFractionDigitState unsignedIntegerValue];
    
    self.maximumFractionDigitState = nil;
    self.minimumFractionDigitState = nil;
}

@end
