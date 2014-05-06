//
//  IAEEmailSender.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailSender.h"
#import <AWSRuntime/AWSRuntime.h>
#import <AWSSES/AWSSES.h>

#pragma mark - Constants

static NSString * const kAWSAccessKeyId = @"REMOVED_AWS_KEY_ID";
static NSString * const kAWSSecretKey = @"REMOVED_AWS_SECRET";

@interface IAEEmailSender()

@property (nonatomic, strong) AmazonSESClient *sesClient;

@end

@implementation IAEEmailSender

#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static IAEEmailSender *sharedInstance = nil;
    static dispatch_once_t onceQueue;
    dispatch_once(&onceQueue, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Properties

- (AmazonSESClient *)sesClient
{
    if (!_sesClient) {
        _sesClient = [[AmazonSESClient alloc] initWithAccessKey:kAWSAccessKeyId withSecretKey:kAWSSecretKey];
    }
    
    return _sesClient;
}

#pragma mark - Actions

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmailTo:(NSString *)destinationEmail
{
    [self.sesClient sendEmail:[self makeEmailRequestForRecoveryPasswordWithDestinationEmail:destinationEmail]];
    //SESSendEmailResponse *response = [sesClient sendEmail:ser];
}

- (void)sendRecoveryPasswordEmailTo:(NSString *)destinationEmail
{
    [self.sesClient sendEmail:[self makeEmailRequestForRecoveryPasswordWithDestinationEmail:destinationEmail]];
    //SESSendEmailResponse *response = [sesClient sendEmail:ser];
}

- (SESSendEmailRequest *)makeEmailRequestForRecoveryPasswordWithDestinationEmail:(NSString *)destinationEmail
{
    SESSendEmailRequest *ser = [[SESSendEmailRequest alloc] init];
    ser.source = @"hola@frodrig.com";
    ser.destination = [self makeDestinationObjectForRecoveryPasswordEmailRequestWithDestinationEmail:destinationEmail];
    ser.message = [self makeMessageObjectForRecoveryPasswordEmailRequest];
    
    return ser;
}

- (SESDestination *)makeDestinationObjectForRecoveryPasswordEmailRequestWithDestinationEmail:(NSString *)destinationEmail
{
    SESDestination *destination = [[SESDestination alloc] init];
    [destination.toAddresses addObject:destinationEmail];

    return destination;
}

- (SESMessage *)makeMessageObjectForRecoveryPasswordEmailRequest
{
    SESMessage *message = [[SESMessage alloc] init];
    message.subject = [self makeSubjectObjectForRecoveryPasswordEmailRequest];
    message.body = [self makeBodyObjectForRecoveryPasswordEmailRequest];
    
    return message;
}

- (SESBody *)makeBodyObjectForRecoveryPasswordEmailRequest
{
    SESBody *body = [[SESBody alloc] init];
    body.text = [self makeMessageBodyObjectForRecoveryPasswordEmailRequest];
    
    return body;
}

- (SESContent *)makeMessageBodyObjectForRecoveryPasswordEmailRequest
{
    SESContent *messageBody = [[SESContent alloc] init];
    messageBody.data = @"Test enviado correo con Amazon SES";

    return messageBody;
}

- (SESContent *)makeSubjectObjectForRecoveryPasswordEmailRequest
{
    SESContent *subject = [[SESContent alloc] init];
    subject.data = @"Title";

    return subject;
}

@end
