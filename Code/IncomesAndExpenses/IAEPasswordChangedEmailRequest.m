//
//  IAEPasswordChangedEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 10/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEPasswordChangedEmailRequest.h"

@implementation IAEPasswordChangedEmailRequest

- (NSString *)findSubjectText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILCHANGEPASSWORD_SUBJECT", @"");
}

- (NSString *)findMessageText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILCHANGEPASSWORD_MESSAGE", @"");
}

@end
