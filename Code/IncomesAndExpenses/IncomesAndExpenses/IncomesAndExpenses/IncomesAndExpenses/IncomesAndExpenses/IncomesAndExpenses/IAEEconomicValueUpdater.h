//
//  IAEEconomicValueUpdater.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 01/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEEconomicValueUpdater : NSObject

+ (IAEEconomicValueUpdater *)defaultEconomicValueUpdater;

- (void)processEconomicLabel:(UILabel *)label toValue:(NSDecimalNumber *)destinationValue withDuration:(CGFloat)duration;

@end
