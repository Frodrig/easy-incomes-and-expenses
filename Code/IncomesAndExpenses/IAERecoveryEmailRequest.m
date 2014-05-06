//
//  IAERecoveryEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERecoveryEmailRequest.h"

@implementation IAERecoveryEmailRequest

- (NSString *)findDestinationEmail
{

    return nil;
}

- (NSString *)findTitleText
{
    NSAssert(NO, @"Se debe sobreescribir en la clase derivada");
    return nil;
}

- (NSString *)findMessageText
{
    NSAssert(NO, @"Se debe sobreescribir en la clase derivada");
    return nil;
}

@end
