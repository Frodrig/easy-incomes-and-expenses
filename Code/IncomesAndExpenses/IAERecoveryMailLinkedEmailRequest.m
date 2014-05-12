//
//  IAERecoveryMailLinkedEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERecoveryMailLinkedEmailRequest.h"

@implementation IAERecoveryMailLinkedEmailRequest

- (NSString *)findSubjectText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILLINKED_SUBJECT", @"");
}

- (NSString *)findMessageText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILLINKED_MESSAGE", @"");
}

@end
