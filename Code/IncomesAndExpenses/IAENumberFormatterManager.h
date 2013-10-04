//
//  IAEFormatters.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 04/10/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAENumberFormatterManager : NSObject

@property (nonatomic, strong, readonly) NSNumberFormatter *currencyFormatter;
@property (nonatomic, strong, readonly) NSNumberFormatter *percentageFormatter;

+ (IAENumberFormatterManager *)sharedManager;

- (void)saveCurrencyFormatterFractionState;
- (void)restoreCurrencyFormatterFractionState;


@end
