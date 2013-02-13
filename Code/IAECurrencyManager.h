//
//  IAECurrencyManager.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAECurrencyInfo;

@interface IAECurrencyManager : NSObject

//@property (nonatomic, strong, readonly) NSMutableArray *currencies;
@property (nonatomic, strong, readonly) NSNumberFormatter *currencyFormatter;

+ (IAECurrencyManager *)sharedManager;

- (NSString *)decimalSeparator;
- (NSString *)groupingSeparator;

//- (void)setUserCurrencyCode:(IAECurrencyInfo *)currency;
//- (IAECurrencyInfo *)findUserCurrencyInfo;

@end
