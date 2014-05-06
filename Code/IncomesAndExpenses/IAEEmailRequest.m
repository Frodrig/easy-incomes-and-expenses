//
//  IAEEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSSES/AWSSES.h>
#import "NSUserDefaults+EasyIncAndExp.h"

@implementation IAEEmailRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepare];
    }
    
    return self;
}

- (void)prepare
{
    SESContent *subject = [[SESContent alloc] init];
    subject.data = @"Title";
    
    SESContent *messageBody = [[SESContent alloc] init];
    messageBody.data = @"Test enviado correo con Amazon SES";
    
    SESBody *body = [[SESBody alloc] init];
    body.text = messageBody;
    
    SESMessage *emailMessage = [[SESMessage alloc] init];
    emailMessage.subject = subject;
    emailMessage.body = body;
    
    SESDestination *emailDestination = [[SESDestination alloc] init];
    [emailDestination.toAddresses addObject:[self findDestinationEmail]];
    
    self.source = [self findSourceEmail];
    self.destination = destination;
    self.message = message;
}

#pragma mark - Metodos a sobreescribir

- (NSString *)findSourceEmail
{
    return @"easyincexp-noreply@frodrig.com";
}

- (NSString *)findDestinationEmail
{
    return [[NSUserDefaults standardUserDefaults] findPasswordRecoveryEmail];
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
