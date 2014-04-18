//
//  IAEEmailChecker.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 18/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEEmailChecker : NSObject

+ (BOOL)isValidEmail:(NSString *)emailString;

@end
