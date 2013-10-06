//
//  IAEFormatters.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAENumberFormatterManager.h"

@interface IAENumberFormatterManager()

@property (nonatomic, strong) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong) NSNumberFormatter *percentageFormatter;
@property (nonatomic, strong) NSNumber *maximumFractionDigitState;
@property (nonatomic, strong) NSNumber *minimumFractionDigitState;

@end

@implementation IAENumberFormatterManager

#pragma mark - Properties

- (NSNumberFormatter *)currencyFormatter
{
    if (!_currencyFormatter) {
        _currencyFormatter = [[NSNumberFormatter alloc] init];
        [_currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
        _currencyFormatter.locale = [NSLocale currentLocale];
        _currencyFormatter.minimumFractionDigits = 2;
        _currencyFormatter.maximumFractionDigits = 2;
        _currencyFormatter.maximumFractionDigits = 2;
        _currencyFormatter.generatesDecimalNumbers = YES;
    }
    
    return _currencyFormatter;
}


- (NSNumberFormatter *)percentageFormatter
{
    if (!_percentageFormatter) {
        _percentageFormatter = [[NSNumberFormatter alloc] init];
        [_percentageFormatter setLocale:[NSLocale currentLocale]];
        [_percentageFormatter setFormatterBehavior:NSNumberFormatterBehaviorDefault];
        [_percentageFormatter setNumberStyle:NSNumberFormatterPercentStyle];
        [_percentageFormatter setMaximumFractionDigits:2];
        [_percentageFormatter setMinimumFractionDigits:2];
    }
    
    return _percentageFormatter;
}

#pragma mark - Class

+ (IAENumberFormatterManager *)sharedManager
{
    // ToDo: Hacerlo con dispatch para evitar acceso concurrente
    static IAENumberFormatterManager *shared = nil;
    if (!shared) {
        shared = [[IAENumberFormatterManager alloc] init];
    }
    
    return shared;
}

#pragma mark - CurrencyFormatter

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

#pragma mark - Percentage Decorator

- (NSString *)convertNumberToDecoratePercentageString:(NSNumber *)value
{
    NSString *stringValue = [[IAENumberFormatterManager sharedManager].percentageFormatter stringFromNumber:value];
    if ([value compare:@0] == NSOrderedSame ||
        [value compare:@0.01] == NSOrderedAscending) {
        stringValue = [NSString stringWithFormat:@"< %@", [[IAENumberFormatterManager sharedManager].percentageFormatter stringFromNumber:@0.0001]];
    }
    
    return stringValue;
}

- (BOOL)isPresentDecoratePercentageInNumberString:(NSString *)percentage
{
    BOOL isPresent = NO;
    if ([percentage rangeOfString:@"%"].location != NSNotFound) {
        isPresent = [percentage rangeOfString:@"<"].location != NSNotFound;
    }
    
    return isPresent;
}



@end
