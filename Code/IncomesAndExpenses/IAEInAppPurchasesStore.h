//
//  IAEInAppPurchasesStore.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class  SKProduct;

@interface IAEInAppPurchasesStore : NSObject

+ (instancetype)defaultStore;

- (void)beginTransationObserverSession;
- (void)endTransactionObserverSessio;

- (BOOL)isInAppPurchasesAccesible;

- (void)requestProVersionProductOnCompletion:(void(^)(SKProduct *product))completionBlock;

- (void)payForProduct:(SKProduct *)product;
- (void)restorePurchasedProducts;

@end
