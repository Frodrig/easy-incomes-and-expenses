//
//  SKProduct+FormatedPrice.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <StoreKit/StoreKit.h>

@interface SKProduct (FormatedPrice)

- (NSString *)formattedPrice;

@end
