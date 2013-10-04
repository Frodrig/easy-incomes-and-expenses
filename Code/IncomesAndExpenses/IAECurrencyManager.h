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

+ (IAECurrencyManager *)sharedManager;

- (NSString *)decimalSeparator;
- (NSString *)groupingSeparator;
- (NSString *)currencySymbol;

@end
