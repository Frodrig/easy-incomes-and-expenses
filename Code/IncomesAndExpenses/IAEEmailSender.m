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

static NSString * const kAWSAccessKeyId = @"AKIAJ7V3LH7KQC3WBXOQ";
static NSString * const kAWSSecretKey = @"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";
static NSString * const kPostmarkAPIKey = @"b4239a78-425f-405e-89bd-b7551d0fad26";

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
        if (error) {
            [self lauchAlertViewWithError:error];
        }
        
        if (completionBlock) {
            completionBlock(error);
        }
    }];
}

- (void)lauchAlertViewWithError:(NSError *)error
{
    NSAssert(error, @"");
    
    NSString *message = [NSString stringWithFormat:@"%@%@", error.localizedDescription, NSLocalizedString(@"LTEXT_EMAILSENDER_ALERTVIEWERROR_POSTMESSAGE", @"")];
    UIAlertView *errorAlertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LTEXT_EMAILSENDER_ALERTVIEWERROR_TITLE", @"")
                                                             message:message
                                                            delegate:nil
                                                   cancelButtonTitle:NSLocalizedString(@"LTEXT_EMAILSENDER_ALERTVIEWERROR_OK", @"")
                                                   otherButtonTitles:nil];
    [errorAlertView show];
}

@end
