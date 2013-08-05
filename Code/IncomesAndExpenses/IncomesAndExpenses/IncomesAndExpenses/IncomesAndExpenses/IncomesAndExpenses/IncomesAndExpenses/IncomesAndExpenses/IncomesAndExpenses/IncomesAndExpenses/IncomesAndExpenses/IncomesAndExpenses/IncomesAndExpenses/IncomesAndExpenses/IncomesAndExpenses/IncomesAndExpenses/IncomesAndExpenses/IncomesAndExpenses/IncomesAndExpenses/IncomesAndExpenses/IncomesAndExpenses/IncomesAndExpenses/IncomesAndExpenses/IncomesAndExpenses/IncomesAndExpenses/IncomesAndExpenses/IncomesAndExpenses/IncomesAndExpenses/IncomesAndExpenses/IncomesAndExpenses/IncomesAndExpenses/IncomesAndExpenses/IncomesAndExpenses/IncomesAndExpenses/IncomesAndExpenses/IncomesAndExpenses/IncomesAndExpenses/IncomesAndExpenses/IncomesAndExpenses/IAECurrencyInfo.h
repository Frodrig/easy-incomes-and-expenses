//
//  IAECurrencyInfo.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 14/12/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAECurrencyInfo : NSObject

@property(nonatomic, strong, readonly) NSString *code;
@property(nonatomic, strong, readonly) NSString *symbol;
@property(nonatomic, strong, readonly) NSString *description;

- (id)initWithCode:(NSString *)code symbol:(NSString *)symbol andDescription:(NSString *)description;

@end
