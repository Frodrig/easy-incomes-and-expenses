//
//  IAEMailUnlinkedEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 12/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEMailUnlinkedEmailRequest.h"

@implementation IAEMailUnlinkedEmailRequest

- (NSString *)findSubjectText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILUNLINKED_SUBJECT", @"");
}

- (NSString *)findMessageText
{
    return NSLocalizedString(@"LTEXT_PASSWORD_EMAILUNLINKED_MESSAGE", @"");
}

@end
