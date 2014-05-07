//
//  IAEEmailSender.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailSender.h"
#import "IAEEmailRequest.h"
#import <AWSRuntime/AWSRuntime.h>

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
        _sesClient.endpoint = [AmazonEndpoints snsEndpoint:EU_WEST_1];
    }
    
    return _sesClient;
}

#pragma mark - Actions

- (void)sendRecoveryPasswordEmail
{
    @try
    {
        SESSendEmailResponse *response = [self.sesClient sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryEmailRequest]];
        NSLog(@"%@", response);
    }
    @catch (NSException *theException)
    {
        NSLog(@"Exception: %@", theException);
    }
}

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmail
{
    @try
    {
        SESSendEmailResponse *response = [self.sesClient sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryMailLinkedEmailRequest]];
        NSLog(@"%@", response);
    }
    @catch (NSException *theException)
    {
        NSLog(@"Exception: %@", theException);
    }

}

@end
