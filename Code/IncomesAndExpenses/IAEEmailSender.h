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

- (void)sendRecoveryPasswordEmailTo:(NSString *)destinationEmail;
- (void)sendConfirmationLinkedMailForRecoveryPasswordEmailTo:(NSString *)destinationEmail;

@end
