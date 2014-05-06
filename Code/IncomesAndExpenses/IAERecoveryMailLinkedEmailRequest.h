//
//  IAERecoveryMailLinkedEmailRequest.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 06/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"

@interface IAERecoveryMailLinkedEmailRequest : IAEEmailRequest

- (NSString *)findSubjectText;
- (NSString *)findMessageText;

@end
