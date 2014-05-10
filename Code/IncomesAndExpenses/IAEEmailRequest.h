//
//  IAEEmailRequest.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "SSPostmarkEmail.h"

typedef NS_ENUM(NSUInteger, IAEEmailRequestType)
{
    RecoveryEmailRequest,
    RecoveryMailLinkedEmailRequest,
    PasswordDisabledEmailRequest,
    PasswordEnabledEmailRequest,
    PasswordChangedEmailRequest
};

@interface IAEEmailRequest : SSPostmarkEmail

+ (id)emailRequestWithType:(IAEEmailRequestType)type;

- (instancetype)init;

// Metodos a sobreescribir en las clases derivadas
// Opcional
- (NSString *)findSourceEmail;
- (NSString *)findNameForSourceEmail;
- (NSString *)findDestinationEmail;

// Obligatorio
- (NSString *)findSubjectText;
- (NSString *)findMessageText;

@end
