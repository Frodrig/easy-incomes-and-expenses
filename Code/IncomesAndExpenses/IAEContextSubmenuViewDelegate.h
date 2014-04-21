//
//  IAEContextSubmenuViewDelegate.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEContextSubmenuView;

@protocol IAEContextSubmenuViewDelegate <NSObject>

- (void)exportCSVOptionWasPressedInContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView;
- (void)removeAllConceptsOptionWasPressedInContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView;

@end
