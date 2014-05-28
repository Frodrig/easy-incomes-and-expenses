//
//  IAEEmailSender.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface IAEEmailSender : NSObject

+ (instancetype)sharedInstance;

- (void)sendConfirmationLinkedMailForRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)sendUnlinkedMailForRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)sendRecoveryPasswordEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)sendPasswordDisabledEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)sendPasswordEnabledEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;
- (void)sendPasswordChangedEmailWithCompletionBlock:(void(^)(NSError *error))completionBlock;

@end
