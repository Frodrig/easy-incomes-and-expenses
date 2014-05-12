//
//  IAERecoveryEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAERecoveryEmailRequest.h"
#import "KeychainItemWrapper.h"

@implementation IAERecoveryEmailRequest

- (NSString *)findSubjectText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILREMEMBERPASSWORD_SUBJECT", @"");
}

- (NSString *)findMessageText
{
    return [NSString stringWithFormat:NSLocalizedString(@"LTEXT_PASSWORD_EMAILREMEMBERPASSWORD_MESSAGE", @""), [[KeychainItemWrapper defaultKeychain] findPassword]];
}

@end
