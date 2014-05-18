//
//  IAEInAppPurchasesStore.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEInAppPurchasesStore.h"
#import <StoreKit/StoreKit.h>


@implementation IAEInAppPurchasesStore

+ (instancetype)defaultStore
{
    static IAEInAppPurchasesStore *defaultStore = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultStore = [[IAEInAppPurchasesStore alloc] init];
    });
    
    return defaultStore;
}

- (BOOL)isInAppPurchasesAccesible
{
    return [SKPaymentQueue canMakePayments];
}

@end
