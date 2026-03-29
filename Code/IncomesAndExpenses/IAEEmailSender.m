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

// API keys removed — do not commit real credentials to public repositories
static NSString * const kAWSAccessKeyId = @"";
static NSString * const kAWSSecretKey = @"";
static NSString * const kPostmarkAPIKey = @"";

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

- (void)sendPasswordDisabledEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:PasswordDisabledEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendPasswordEnabledEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:PasswordEnabledEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendPasswordChangedEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:PasswordChangedEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:RecoveryEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:RecoveryMailLinkedEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendUnlinkedMailForRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self sendEmailRequestOfType:MailUnlinkedEmailRequest withCompletionBlock:completionBlock];
}

- (void)sendEmailRequestOfType:(IAEEmailRequestType)emailRequestType withCompletionBlock:(void(^)(NSError *error))completionBlock
{
    [self.postmark sendEmail:[IAEEmailRequest emailRequestWithType:emailRequestType] completion:^(BOOL success, NSError *error) {
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

@end
