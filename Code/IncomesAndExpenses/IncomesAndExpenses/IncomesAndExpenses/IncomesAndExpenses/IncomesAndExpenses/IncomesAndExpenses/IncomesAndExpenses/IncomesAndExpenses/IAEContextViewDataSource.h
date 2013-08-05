//
//  IAEContextViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez on 26/07/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IAEContextViewDefs.h"

@class IAEContextView;

@protocol IAEContextViewDataSource <NSObject>

- (NSString *)nameForContextView:(IAEContextView *)contextView;
- (NSDecimalNumber *)balanceForContextView:(IAEContextView *)contextView;

@end

