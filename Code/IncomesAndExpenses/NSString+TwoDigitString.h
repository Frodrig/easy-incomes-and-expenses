//
//  NSString+TwoDigitString.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 18/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (TwoDigitString)

+ (NSString *)stringWithAtLastTwoDigitFromNumber:(NSNumber *)number;

@end
