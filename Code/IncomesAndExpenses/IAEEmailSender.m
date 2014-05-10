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
