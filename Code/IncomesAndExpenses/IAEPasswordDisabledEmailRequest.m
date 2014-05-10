//
//  IAEPasswordDisabledEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 10/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordDisabledEmailRequest.h"

@implementation IAEPasswordDisabledEmailRequest

- (NSString *)findSubjectText
{
    return @"Test";
}

- (NSString *)findMessageText
{
    return @"Test";
}

@end
