//
//  IAEEmailRequest.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"
#import "IAERecoveryEmailRequest.h"
#import "IAERecoveryMailLinkedEmailRequest.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSSES/AWSSES.h>
#import "NSUserDefaults+EasyIncAndExp.h"

@implementation IAEEmailRequest

#pragma mark - Class

+ (id)emailRequestWithType:(IAEEmailRequestType)type
{
    IAEEmailRequest *retRequest = nil;
    switch (type) {
        case RecoveryEmailRequest:
            retRequest = [[IAERecoveryEmailRequest alloc] init];
            break;
            
        case RecoveryMailLinkedEmailRequest:
            retRequest = [[IAERecoveryMailLinkedEmailRequest alloc] init];
            break;
            
        default:
            break;
    }
    
    return retRequest;
}

#pragma mark - Init

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self prepareRequest];
    }
    
    return self;
}

- (void)prepareRequest
{
    self.source = [self findSourceEmail];
    self.destination = [self createEmailDestination];
    self.message = [self createEmailMessage];
}

- (SESDestination *)createEmailDestination
{
    SESDestination *emailDestination = [[SESDestination alloc] init];
    [emailDestination.toAddresses addObject:[self findDestinationEmail]];

    return emailDestination;
}

- (SESMessage *)createEmailMessage
{
    SESContent *emailSubject = [[SESContent alloc] init];
    emailSubject.data = [self findSubjectText];
    
    SESContent *emailMessageBody = [[SESContent alloc] init];
    emailMessageBody.data = [self findMessageText];
    
    SESBody *body = [[SESBody alloc] init];
    body.text = emailMessageBody;
    
    SESMessage *emailMessage = [[SESMessage alloc] init];
    emailMessage.subject = emailSubject;
    emailMessage.body = body;
    
    return emailMessage;
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

- (NSString *)findSubjectText
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
