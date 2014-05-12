//
//  IAEPasswordEnabledEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 10/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordEnabledEmailRequest.h"

@implementation IAEPasswordEnabledEmailRequest

- (NSString *)findSubjectText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILACTIVATEPASSWORDMODE_SUBJECT", @"");
}

- (NSString *)findMessageText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILACTIVATEPASSWORDMODE_MESSAGE", @"");
}

@end
