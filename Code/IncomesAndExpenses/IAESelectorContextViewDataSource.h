//
//  IAESelectorContextViewDataSource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 22/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAESelectorContextView;

@protocol IAESelectorContextViewDataSource <NSObject>

- (NSUInteger)numberOfConceptsForSelectorContextView:(IAESelectorContextView *)selectorContextView atIndex:(NSUInteger)index;

@end
