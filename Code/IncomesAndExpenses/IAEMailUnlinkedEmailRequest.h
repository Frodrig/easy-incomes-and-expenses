//
//  IAEMailUnlinkedEmailRequest.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 12/05/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import "IAEEmailRequest.h"

@interface IAEMailUnlinkedEmailRequest : IAEEmailRequest

- (NSString *)findSubjectText;
- (NSString *)findMessageText;

@end
