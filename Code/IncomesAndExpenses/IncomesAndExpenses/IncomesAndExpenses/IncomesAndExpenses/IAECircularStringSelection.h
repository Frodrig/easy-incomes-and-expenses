//
//  IAECircularStringSelection.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 30/11/12.
//  Copyright (c) 2012 Fernando Rodríguez Martínez. All rights reserved.
//

// Mantiene un array de strings y un indice
// El indice se puede incrementar o decrementar y avanza o retrocede de manera circular

#import <Foundation/Foundation.h>

@interface IAECircularStringSelection : NSObject

@property (nonatomic, readonly) NSArray *stringSelection;
@property (nonatomic, readonly) NSUInteger index;

- (id)init:(NSArray *)selection;

- (void)advance;
- (void)rewind;

- (NSString *)actualSelection;

@end
