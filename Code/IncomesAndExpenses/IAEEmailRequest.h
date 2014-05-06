//
//  IAEEmailRequest.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <AWSSES/AWSSES.h>

typedef NS_ENUM(NSUInteger, IAEEmailRequestType)
{
    RecoveryEmailRequest,
    RecoveryMailLinkedEmailRequest,
};

@interface IAEEmailRequest : SESSendEmailRequest

+ (id)emailRequestWithType:(IAEEmailRequestType)type;

- (instancetype)init;

// Metodos a sobreescribir en las clases derivadas
- (NSString *)findSourceEmail;
- (NSString *)findDestinationEmail;
- (NSString *)findSubjectText;
- (NSString *)findMessageText;

@end
