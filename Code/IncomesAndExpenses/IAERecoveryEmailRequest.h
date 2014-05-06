//
//  IAERecoveryEmailRequest.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"

@interface IAERecoveryEmailRequest : IAEEmailRequest

- (NSString *)findTitleText;
- (NSString *)findMessageText;

@end
