//
//  IAEInAppPurchasesStore.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEInAppPurchasesStore : NSObject

+ (instancetype)defaultStore;

- (BOOL)isInAppPurchasesAccesible;

@end
