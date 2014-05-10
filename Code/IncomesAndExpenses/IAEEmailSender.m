//
//  IAEEmailSender.m
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailSender.h"
#import "IAEEmailRequest.h"
#import "SSPostmark.h"
#import "SSPostmarkEmail.h"

#pragma mark - Constants

static NSString * const kAWSAccessKeyId = @"REMOVED_AWS_KEY_ID";
static NSString * const kAWSSecretKey = @"REMOVED_AWS_SECRET";
static NSString * const kPostmarkAPIKey = @"REMOVED_POSTMARK_TOKEN";

@interface IAEEmailSender()

@property (nonatomic, strong) SSPostmark *postmark;

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

- (SSPostmark *)postmark
{
    if (!_postmark) {
        _postmark = [[SSPostmark alloc] initWithApiKey:kPostmarkAPIKey];
    }
    
    return _postmark;
}

#pragma mark - Actions

- (void)sendRecoveryPasswordEmail
{
    [self.postmark sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryEmailRequest] completion:^(BOOL success, NSError *error) {
        NSAssert(!error, @"");
    }];
}

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmail
{
    [self.postmark sendEmail:[IAEEmailRequest emailRequestWithType:RecoveryMailLinkedEmailRequest] completion:^(BOOL success, NSError *error) {
        NSAssert(!error, @"");
    }];
}

@end
