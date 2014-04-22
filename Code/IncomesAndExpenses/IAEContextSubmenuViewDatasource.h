//
//  IAEContextSubmenuViewDatasource.h
//  IncomesAndExpenses
//
//  Created by Fernando Rodríguez Martínez on 21/04/14.
//  Copyright (c) 2014 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class IAEContextSubmenuView;

@protocol IAEContextSubmenuViewDatasource <NSObject>

- (BOOL)isActualContextAYearForContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView;
- (BOOL)isActualContextAMonthForContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView;

- (BOOL)isActualContextWithConceptsForContextSubmenuView:(IAEContextSubmenuView *)contextSubmenuView;

@end
